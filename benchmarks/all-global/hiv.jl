using ModelingToolkit, DifferentialEquations
using ParameterEstimation
solver = Tsit5()

@parameters lm d beta a k u c q b h
@variables t x(t) y(t) v(t) w(t) z(t) y1(t) y2(t) y3(t) y4(t)
D = Differential(t)
states = [x, y, v, w, z]
parameters = [lm, d, beta, a, k, u, c, q, b, h]

@named model = ODESystem([
                             D(x) ~ lm - d * x - beta * x * v,
                             D(y) ~ beta * x * v - a * y,
                             D(v) ~ k * y - u * v,
                             D(w) ~ c * x * y * w - c * q * y * w - b * w,
                             D(z) ~ c * q * y * w - h * z,
                         ], t, states, parameters)
measured_quantities = [y1 ~ w, y2 ~ z, y3 ~ x, y4 ~ y + v]

ic = [1.0, 1.0, 1.0, 1.0, 1.0]
time_interval = [0.0, 20.0]
datasize = 20
p_true = [0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1]
data_sample = ParameterEstimation.sample_data(model, measured_quantities, time_interval,
                                              p_true, ic,
                                              datasize; solver = solver)
ParameterEstimation.write_sample(data_sample;
                                 filename = "../matlab/amigo_models/hiv-$datasize-$(time_interval[1])-$(time_interval[end]).txt")

# identifiability_result = ParameterEstimation.check_identifiability(model;
#                                                                    measured_quantities = measured_quantities)
# interpolation_degree = 7
# res = ParameterEstimation.estimate(model, measured_quantities, data_sample,
#                                    time_interval, identifiability_result,
#                                    interpolation_degree)

# filtered = ParameterEstimation.filter_solutions(res, identifiability_result, model,
#                                                 data_sample, time_interval; solver = solver)
# print(filtered)
res = ParameterEstimation.estimate_over_degrees(model, measured_quantities, data_sample,
                                                time_interval; solver = solver)
print(res)