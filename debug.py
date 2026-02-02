import sys
from antlr4 import *
from BKITLexer import BKITLexer
from lexererr import *

def debug_lexer(input_string):
    print(f"--- Đang test: {input_string} ---")
    try:
        input_stream = InputStream(input_string)
        lexer = BKITLexer(input_stream)
        token = lexer.nextToken()
        
        while token.type != Token.EOF:
            # Token.type là số hiệu (ví dụ 1, 2...), Token.text là nội dung
            print(f"Token Type: {token.type}, Text: '{token.text}'") 
            token = lexer.nextToken()
            
        print("--> Kết quả: THÀNH CÔNG (Hết file)\n")
        
    except (ErrorToken, UncloseString, IllegalEscape) as e:
        print(f"--> BẮT ĐƯỢC LỖI: {e.message}\n")

# --- THAY ĐỔI INPUT CỦA BẠN Ở ĐÂY ĐỂ CHECK ---
debug_lexer("Var x;")          # Test biến
debug_lexer('"abc\\h"')        # Test lỗi escape
debug_lexer('"abc def')        # Test lỗi thiếu ngoặc``