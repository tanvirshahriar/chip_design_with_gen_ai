def sat_adder8_golden(a, b):
    total = a + b
    if total <= 255:
        sum_val = total
        sat_val = 0
    else:
        sum_val = 255
        sat_val = 1
    return {'sum': sum_val, 'sat': sat_val}