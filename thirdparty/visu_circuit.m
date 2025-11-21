function visu_circuit(circuit)

[n,p] = size(circuit);

figure(1)
set(gcf,'units','centimeters','position',[0,0,20,20])

hold on

for i = 1 : n
    y = n-i+.5;
    for j = 1 : p
        x = j-.5;

        if circuit(i,j) == 0
            plot(x,y,'sk','MarkerSize',15,'MarkerFaceColor','k') % mur
        else
            text(x-.1,y,num2str(circuit(i,j)),'FontSize',8)   % n° case
        end
    end
end

set(gca,'XTick',1:n,'YTick',1:p)

grid on
axis equal
axis([0 p 0 n])
