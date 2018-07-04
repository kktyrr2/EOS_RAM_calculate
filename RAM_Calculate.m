clear all;

R_init = 1e14;
EOS_init = 1e6;
CONST_F = 5e-4;
CONST_F_2 = 2e3;
TOTAL_RAM = 64; %in GB

GB_to_KB = 1024*1024;
RAM_increment = 2; %used to simulate RAM supply increase, set to 0 if not using
increment_flag = 0;
RAM_multiply = 1; %used to simulate RAM supply increase, set to 1 if not using


R = R_init;
C1 = EOS_init; %Total EOS in RAM system
C2 = TOTAL_RAM*GB_to_KB; %in KB, remaining RAM
T = 50; %Amount of EOS used in buying RAM, each iteration

iter = 1e6;
E_log = zeros(1,iter);
T_2_log = zeros(1,iter);
C1_log = zeros(1,iter);
C2_log = zeros(1,iter);
price_log = zeros(1,iter);
RAM_used_percent_log = zeros(1,iter);

for i=1:iter
    E = -1*R_init*(1-((1+T/C1)^CONST_F));
    C1 = C1 + T;
    T_2 = C2*(((1+E/(R))^CONST_F_2)-1);
    C2 = C2 - T_2; %in KB
    
    price = T/T_2;
    RAM_used_percent = (TOTAL_RAM*1024*1024-C2)/(TOTAL_RAM*1024*1024);
    
    %%
    
    if RAM_used_percent > 0.9
        C2 = C2 + (RAM_multiply-1)*TOTAL_RAM*GB_to_KB;
        TOTAL_RAM = TOTAL_RAM*RAM_multiply;
    end
    %% 
    if RAM_used_percent > 0.9
        increment_flag = TOTAL_RAM/RAM_increment;
    end
    if increment_flag>0
        if rem(i, 1000) == 0
            C2 = C2 + RAM_increment*GB_to_KB;
            TOTAL_RAM = TOTAL_RAM + RAM_increment;
            increment_flag = increment_flag - 1;
        end
    end
    %% save data point
    E_log(i) = E;
    T_2_log(i) = T_2;
    C1_log(i) = C1;
    C2_log(i) = C2;
    price_log(i) = price;
    RAM_used_percent_log(i) = RAM_used_percent;
end

f1 = figure();
yyaxis left
title_string = strcat('RAM Price and total EOS in Pool vs. RAM Utilization (System total RAM supply:', {' '}, num2str(TOTAL_RAM), ' GB)');
title(title_string, 'FontSize', 18);
xlabel('RAM Utilization (percent)', 'FontSize', 18);

plot(RAM_used_percent_log*100, price_log);
ylabel('Price of RAM (EOS/KB)', 'FontSize', 18);
yyaxis right
plot(RAM_used_percent_log*100, C1_log);
ylabel('Total EOS in Pool', 'FontSize', 18);

f2 = figure();
plot(i, price_log);
