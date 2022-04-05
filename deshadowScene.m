function output = deshadowScene(Radiance, Reflectance)

clc;
[h, w, b] = size(Radiance);

outputWS = estLwLbWholeScene(Radiance, Reflectance); % global
[Lw_map, Lb_map] = LwLbSlidingWindow(Radiance, Reflectance); % local

Lw_map = reshape(Lw_map, [h*w, b]);
Lb_map = reshape(Lb_map, [h*w, b]);

%% Shadow Detection
alphaLocal = Lw_map ./ (outputWS.Lw - outputWS.Lb); % equation 11
alphaGlobal = outputWS.Lw ./ (outputWS.Lw - outputWS.Lb);

betaLocal = Lb_map ./ (outputWS.Lw - outputWS.Lb); % equation 12
betaGlobal = outputWS.Lb ./ (outputWS.Lw - outputWS.Lb);

Reflectance = reshape(Reflectance, [h*w, b]);
fk = (Reflectance - betaLocal) ./ alphaLocal; % equation 24a
fg = (Reflectance - betaGlobal) ./ alphaGlobal; % equation 24b

t = fk ./ fg; % equation 25
t1 = zeros(h*w, 1);
for px = 1:h*w
    t1(px) = findF(t(px, :));
end
output.intermediateMap = reshape(t1, [h, w]);

gamma = alphaLocal ./ alphaGlobal; % equation 18a
delta = (betaLocal - betaGlobal)./betaGlobal; % equation 18b
Lns = gamma .* reshape(Radiance, [h*w, b]) + delta;
output.correctedRadiance = reshape(Lns, [h, w, b]);

end