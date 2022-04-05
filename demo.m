function output = demo

% demo with modesto scene
load('/modesto_resize.mat');

output = deshadowScene(radiance, reflectance);
save('/output', 'output');

end
