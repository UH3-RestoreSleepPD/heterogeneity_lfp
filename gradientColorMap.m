function [outputArg1,outputArg2] = gradientColorMap(inputArg1,inputArg2)




% create a default color map ranging from red to light pink
length = 5;
red = [1, 0, 0];
pink = [255, 192, 203]/255;
colors_p = [linspace(red(1),pink(1),length)', linspace(red(2),pink(2),length)', linspace(red(3),pink(3),length)'];
% plot random markers on the map and assign them the colors created
S=10;   % marker size
geoshow(randi([-90,90]),randi([-180,180]), 'DisplayType', 'point','marker','^','MarkerEdgeColor','k','MarkerFaceColor',colors_p(1,:),'markersize',S); hold on;
geoshow(randi([-90,90]),randi([-180,180]), 'DisplayType', 'point','marker','^','MarkerEdgeColor','k','MarkerFaceColor',colors_p(2,:),'markersize',S); hold on;
geoshow(randi([-90,90]),randi([-180,180]), 'DisplayType', 'point','marker','^','MarkerEdgeColor','k','MarkerFaceColor',colors_p(3,:),'markersize',S); hold on;
geoshow(randi([-90,90]),randi([-180,180]), 'DisplayType', 'point','marker','^','MarkerEdgeColor','k','MarkerFaceColor',colors_p(4,:),'markersize',S); hold on;
geoshow(randi([-90,90]),randi([-180,180]), 'DisplayType', 'point','marker','^','MarkerEdgeColor','k','MarkerFaceColor',colors_p(5,:),'markersize',S); hold on;
legend('a', 'b', 'c', 'd', 'e', 'Location', 'northwestoutside')
legend('boxoff')





end