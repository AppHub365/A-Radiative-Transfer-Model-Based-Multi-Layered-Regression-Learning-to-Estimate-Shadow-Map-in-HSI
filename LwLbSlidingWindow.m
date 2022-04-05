function [Lw_map, Lb_map] = LwLbSlidingWindow(Radiance, Reflectance)
[hImage, wImage, b] = size(Radiance);
Lw_map = zeros(hImage, wImage, b);
Lb_map = zeros(hImage, wImage, b);

for i = 1:hImage
    for j = 1:wImage
        Nposi = [i-1, i, i+1]; Nposi(Nposi<1) = []; Nposi(Nposi > hImage) = [];
        Nposj = [j-1, j, j+1]; Nposj(Nposj<1) = []; Nposj(Nposj > wImage) = [];
        radianceN = Radiance(Nposi, Nposj, :);
        reflectanceN = Reflectance(Nposi, Nposj, :);       
        [Lw_map(i, j, :), Lb_map(i, j, :)] = estLwLb_pixel(radianceN, reflectanceN, squeeze(Radiance(i, j, :)), squeeze(Reflectance(i, j, :)));
    end
end

end

function [Lw, Lb] = estLwLb_pixel(radianceROI, reflectanceROI, rad1, ref1)

[h, w, b] = size(radianceROI);
radianceROI = reshape(radianceROI, [h*w, b]);
reflectanceROI = reshape(reflectanceROI, [h*w, b]);
L_all = zeros(2, b);
for pos = 1:h*w-1
    if(reflectanceROI(pos, :) == ref1)
        continue;
    end
    r1 = ref1';
    r2 = reflectanceROI(pos, :);
    lhs = (1 - r1)./r1 - (1 - r2)./r2;
    rhs = rad1'./r1 - radianceROI(pos, :)./r2;
    
    % for divide by 0 (absorption bands)
    lhs(isnan(lhs)) = 0; rhs(isnan(rhs)) = 0;
    lhs(isinf(lhs)) = 0; rhs(isinf(rhs)) = 0;
    
    Lb = rhs./lhs; Lb(isnan(Lb)) = 0; Lb(isinf(Lb)) = 0; % local Lb estimation
    Lw = (rad1' - (1 - r1).*Lb)./r1; % local Lw estimation
    Lw(isnan(Lw)) = 0; Lw(isinf(Lw)) = 0; % for absorption bands
    L_all = L_all + [Lw; Lb]; % update Lw and Lb
end
Lw = L_all(1, :)/(h*w - 1);
Lb = L_all(2, :)/(h*w - 1);

end