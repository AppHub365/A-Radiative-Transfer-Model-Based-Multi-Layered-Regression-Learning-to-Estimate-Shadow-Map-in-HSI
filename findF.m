function f = findF(fracAllBands)

fracAllBands(fracAllBands == 0) = [];
fracAllBands(isnan(fracAllBands)) = [];
fracAllBands(isinf(fracAllBands)) = [];
f = mean(fracAllBands); % starting point
step_s = 0.01; % initial step size
tot = sum(exp(-abs(f - fracAllBands)));
while step_s > 1e-10
    totDec = sum(exp(-abs(f-step_s - fracAllBands)));
    totInc = sum(exp(-abs(f+step_s - fracAllBands)));
    if(tot < totDec)
        tot = totDec;
        f = f - step_s;
    elseif(tot < totInc)
        tot = totInc;
        f = f + step_s;
    else
        break;
    end
    step_s = step_s * 0.995; % decay
end

end