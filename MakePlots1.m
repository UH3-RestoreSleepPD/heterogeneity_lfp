function MakePlots(X,Y)

Al = X;
Rl = Y;

scatter(Al,Rl);

[r,Pval,RL,RU]  = corrcoef(Al,Rl);

poly = polyfit(Al,Rl,1);

% The slope of the regression:
beta = poly(1);
% The y-intercept of the regression:
alpha = poly(2);

x_axis = 0:0.1:max(Al);
y_axis = beta*x_axis+alpha;
hold on
plot(x_axis,y_axis)
xlabel('Multi-Variate Model')
ylabel('PBF from Siri Eq.')
title(['R^2 = ',num2str(r(1,2)^2),' m = ',num2str(beta),' b = ',num2str(alpha)])

end

