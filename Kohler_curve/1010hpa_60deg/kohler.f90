!kohler curve
!p=1010hPa, T=60℃の条件下でのKohler curveを計算
!bを変化させて、S_maxが1.01 (過飽和度1%) になる値を調査する
program kohler_curve
implicit none
            !########## Set value ##########
integer ::                     i, j
real ::                        start_time, finish_time ! for counting Cpu_time.
double precision, parameter :: dr   = 0.001d-6, &
                               rmax = 10d-6 ! 10 micro meter
integer, parameter          :: nr   = int(rmax / dr)
            !########## Parameter ########## 
double precision, parameter :: pi   = 3.14159265d0
double precision, parameter :: T    = 333.15d0  ! [K]　周囲温度
double precision, parameter :: T0   = 273.15d0  ! [K] 
double precision, parameter :: Tc   = T - T0  ! [℃]
double precision, parameter :: Rhow = 9.97d2 ! [kg/m^3] dnsity of water(p.2)
double precision, parameter :: Rv   = 461.51d0 ! gas constant [J/kg/K](water vapor)
double precision, parameter :: sigma = 76.10d0 - 0.155d0 * Tc ![dyn/cm] = [mN/m]
!double precision, parameter :: vhf  = 1.867d0, &! van't hoff factor
!double precision, parameter :: mv   = 18.016d0  ! water molecular weight 
!double precision, parameter :: M    = 1.0d-14 ! mass of solute [g]
!double precision, parameter :: ms   = 58.44d0 ! solute molecular weight [g/mol]

            !########## Variable ########## 
double precision :: s, r, a, b, s_max, r_crit
double precision :: b_start, b_end, log_b, best_b, min_diff, target_s
integer :: num_steps

            !########## Calculation ########## 
a = (2 * sigma * 1.0d-3) / (Rv * Rhow * T)
!b = (3 * vhf * mv * M * 1.0d-3) / (4 * pi * Rhow * ms)

            !########## Survey Settings ##########
b_start = 1.0d-27
b_end   = 1.0d-20
num_steps = 100000
target_s = 1.01d0
min_diff = 1.0d30

print *, "Surveying b from ", b_start, " to ", b_end
print *, "Target S_max = ", target_s

open(unit = 11, file = "./b_survey.dat", status = "replace", action = "write")
write(11, *) "b", "s_max", "supersaturation(%)"

do j = 0, num_steps
    ! 対数スケールでbを変化させる
    log_b = log10(b_start) + (log10(b_end) - log10(b_start)) * dble(j) / dble(num_steps)
    b = 10.0d0**log_b
    
    ! --- Calculate S_max for current b ---
    s_max = 0.0d0
    r = 0.005d-6 ! Start 
    do i = 0, nr
        r = r + dr
        s = 1.0d0 + a/r - b/(r**3) 
        if (s > s_max) s_max = s
    end do
    
    write(11, '(E14.6, 1X, F10.6, 1X, F10.4)') b, s_max, (s_max - 1.0d0)*100.0d0
    
    if (abs(s_max - target_s) < min_diff) then
        min_diff = abs(s_max - target_s)
        best_b = b
    end if
end do
close(11)

print *, "------------------------------------------------"
print *, "Finished."
print *, "Best b : ", best_b
print *, "Difference from target: ", min_diff
print *, "------------------------------------------------"

            !########## Final Calculation with Best b ##########
b = best_b
s = 0.0d0 
r = 0.032d-6 ! Start
s_max = 0.0d0

open(unit = 10, file = "./kohler.dat", status = "replace", action = "write")
call cpu_time(start_time)

do i = 0, nr
    r = r + dr
    
    if (s > s_max) then
        s_max = s
        r_crit = r
    end if

    s = 1.0d0 + a/r - b/(r**3) 
    
    write(10,'(F16.5,1X,F14.4)') r * 1.0d6, s * 100.0d0
end do
close(10)

print *, "a : ", a
print *, "b : ", b
print *, "Tc : ", Tc, "[℃]"
print *, "------------------------------------------------"
print *, "analytical r_crit (um) : ", ( (3.0d0 * b) / a )**(1.0d0/2.0d0) * 1.0d6
print *, "numerical r_crit (um)  : ", r_crit * 1.0d6 
print *, "difference r_crit (um) : ", (( (3.0d0 * b) / a )**(1.0d0/2.0d0) * 1.0d6) - (r_crit * 1.0d6)
print *, "analytical s_crit (%)  : ", (( (4.0d0 * a**3) / (27.0d0 * b) )**(1.0d0/2.0d0)) * 100.0d0
print *, "numerical s_crit (%)   : ", (s_max - 1.0d0) * 100.0d0
print *, "difference s_crit      : ", ((( (4.0d0 * a**3) / (27.0d0 * b) )**(1.0d0/2.0d0)) * 100.0d0) - ((s_max - 1.0d0) * 100.0d0)
print *, "------------------------------------------------"
call cpu_time(finish_time)
print*,"Fortran execution time (seconds): ",finish_time - start_time

end program kohler_curve