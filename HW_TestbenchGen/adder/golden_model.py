def adder4bit_golden(a, b):
    total = a + b
    sum_val = total & 0xF
    carry = 1 if total > 15 else 0
    return {'sum': sum_val, 'carry': carry}

a = 0; b = 0; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 15; b = 0; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 0; b = 15; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 15; b = 15; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 8; b = 8; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 8; b = 7; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 7; b = 7; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 1; b = 14; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 1; b = 2; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 4; b = 6; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 9; b = 9; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 13; b = 2; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 5; b = 10; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 0; b = 7; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 14; b = 1; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 3; b = 12; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 6; b = 8; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 11; b = 4; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 7; b = 9; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))
a = 15; b = 1; out = adder4bit_golden(a, b); print("a={}, b={} => sum={}, carry={}".format(a, b, out['sum'], out['carry']))