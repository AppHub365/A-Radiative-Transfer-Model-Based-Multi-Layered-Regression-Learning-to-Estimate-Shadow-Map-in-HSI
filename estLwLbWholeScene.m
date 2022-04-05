function output = estLwLbWholeScene(Radiance, Reflectance)

[h, w, b] = size(Radiance);
Radiance = reshape(Radiance, [h*w, b]);
Reflectance = reshape(Reflectance, [h*w, b]);
L_all = zeros(2, b);
diff = rand(2, b);
step_s = 0.01;
iter = 1;
while(sum(sum(abs(L_all - diff))) > 1e-10) % iterate till convergence
    diff = L_all;
    pos = ceil(h*w*rand(1, 2)); %random selection of 2 pixels
    r1 = Reflectance(pos(1), :);
    r2 = Reflectance(pos(2), :);
    lhs = (1 - r1)./r1 - (1 - r2)./r2;
    rhs = Radiance(pos(1), :)./r1 - Radiance(pos(2), :)./r2;
    lhs(isnan(lhs)) = 0; rhs(isnan(rhs)) = 0; % for divide by 0 (absorption bands)
    lhs(isinf(lhs)) = 0; rhs(isinf(rhs)) = 0; % for divide by 0 (absorption bands)
    Lb = rhs./lhs; Lb(isnan(Lb)) = 0; Lb(isinf(Lb)) = 0; % local Lb estimation
    Lw = (Radiance(pos(1), :) - (1 - r1).*Lb)./r1; % local Lw estimation
    Lw(isnan(Lw)) = 0; Lw(isinf(Lw)) = 0; % for absorption bands
    if(iter == 1)
        L_all = [Lw; Lb];
    else
        L_all = (1 - step_s) .* L_all + step_s .* [Lw; Lb]; % update Lw and Lb
    end
    step_s = step_s * 0.995; % update step size
    disp(strcat("Iteration: ", num2str(iter), ", step size: ", num2str(step_s)));
    iter = iter + 1;
end

output.Lw = L_all(1, :);
output.Lb = L_all(2, :);

end