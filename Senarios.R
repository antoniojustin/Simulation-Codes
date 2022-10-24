source(Senarios.R)

set.seed(100)
R1 = Simulation(hosp_coef_1 = 1.6, hosp_coef_2 = 1.6, tp1 = 0.2)
R1.1 = Simulation(B = 1000, hosp_coef_1 = 1.6, hosp_coef_2 = 1.6, tp1 = 0.2)
R1.2 = Simulation(B = 1000, patients_num = 10000, hosp_coef_1 = 1.6, hosp_coef_2 = 1.6, tp1 = 0.2)

set.seed(100)
R2 = Simulation(hosp_coef_1 = 1.6, hosp_coef_2 = -1, tp1 = 0.2)
R2.1 = Simulation(B = 1000, hosp_coef_1 = 1.6, hosp_coef_2 = -1, tp1 = 0.2)
R2.2 = Simulation(B = 1000, patients_num = 10000, hosp_coef_1 = 1.6, hosp_coef_2 = -1, tp1 = 0.2)

set.seed(100)
R3 = Simulation(hosp_coef_1 = 1.6, hosp_coef_2 = -1, tp1 = 0.2, tp2 = 0.2)
R3.1 = Simulation(B = 1000, hosp_coef_1 = 1.6, hosp_coef_2 = -1, tp1 = 0.2, tp2 = 0.2)
R3.2 = Simulation(B = 1000, patients_num = 10000, hosp_coef_1 = 1.6, hosp_coef_2 = -1, tp1 = 0.2, tp2 = 0.2)

set.seed(100)
R4 = Simulation(hosp_coef_1 = 1.6, hosp_coef_2 = 0.4, tp1 = 0.2, tp2 = 0.2)
R4.1 = Simulation(B = 1000, hosp_coef_1 = 1.6, hosp_coef_2 = 0.4, tp1 = 0.2, tp2 = 0.2)
R4.2 = Simulation(B = 1000, patients_num = 10000, hosp_coef_1 = 1.6, hosp_coef_2 = 0.4, tp1 = 0.2, tp2 = 0.2)

