def mux2to1_golden(a, b, sel):
    y = b if sel else a
    return {'y': y}