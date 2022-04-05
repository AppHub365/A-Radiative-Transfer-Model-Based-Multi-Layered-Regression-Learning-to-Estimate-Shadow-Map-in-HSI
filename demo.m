function output = demo

% demo with modesto scene
load('/data/modesto_resize.mat');

output = deshadowScene(radiance, reflectance);
save('/results/output', 'output');

end