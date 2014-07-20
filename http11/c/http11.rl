/* Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stddef.h>
#include <stdio.h>

#include "http11.h"


%%{
    machine http_parser;

    action mark {
        parser->mark = fpc - data;
    }

    action request_method {
        printf("%.*s", fpc - data - parser->mark, data + parser->mark);
    }

    CRLF = ( "\r\n" | "\n" ) ;
    SP = " " ;

    tchar = ( "!" | "#" | "$" | "%" | "&" | "'" | "*" | "+" | "-" | "." | "^" |
              "_" | "`" | "|" | "~" | digit | alpha ) ;
    token = tchar+ ;


    method = token >mark %request_method ;
    request_target = ( any -- CRLF )+ ;
    http_version = "HTTP" "/" digit "." digit ;

    request_line = method SP request_target SP http_version CRLF ;
    http_message = ( request_line ) CRLF ;

main := http_message;

}%%


%% write data;


void http_parser_init(http_parser *parser) {
    %% access parser->;
    %% write init;

    parser->mark = 0;

    parser->finished = false;
    parser->error = 0;
}

size_t http_parser_execute(http_parser *parser, const char *data, size_t len, size_t off) {
    const char *p = data + off;
    const char *pe = data + len;

    %% access parser->;
    %% write exec;

    if (parser->cs == http_parser_error || parser->cs >= http_parser_first_final ) {
        parser->finished = true;

        if (parser-> cs == http_parser_error && !parser->error) {
            parser->error = 1;
        }
    }

    return 1;
}
