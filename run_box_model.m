% Wrapper script to configure and run the Haine & Hall (2002) box model.
% twnh Sep 00, Aug 02, Oct, 11.

% Housekeeping
more off
close all
clear global
clear all

% Define global variables that specify the box-model transport:
global A B

fprintf(1,'\n\n Sample script to configure and run box model.\n') ;
fprintf(1,' Tom Haine, Sep 2000, Aug 2002, Oct, 2011.\n\n') ;

% Define flow. S = NAtl sinking, d = diapycnal diffusion, I = intermediate outflow, m = exchange flux with mixed layer (boundary) box.
% Fluxes are (nominally) in Sv, Vol in Sv.yr, times in years.
S = 20.0 ;
d = 5.0 ;
I = 10.0 ;
m = [20 10 0 0 0 0 0 0 0] ;
Vol = 300 ;

% Define transport operator. Row = box receiving flux, column = donating box.
Ai = [
    -S       S-d     0      d        0        0     0     0     0
     0      -S       S-d    0        d        0     0     0     0
     0       0     d-S      0        0        S-d   0     0     0
     S       0       0 -(S+d)        0        0     d     0     0
     0       d       0      I -(I+2*d)        0     0     d     0
     0       0       0      0        I       -S     0     0   S-I
     0       0       0    S-I        0        0   I-S     0     0
     0       0       0      0        d        0 S-I-d   I-S     0
     0       0       0      0        0        d     0 S-I-d   I-S ] ;

% Define boundary conditions (communication with surface boxes).
B = diag(m) ;

% Scale Ai and B matrices; times are in years, fluxes in Sv, Volume in Sv.s.
Ai = Ai./Vol ;
B  = B ./Vol ;
m  = m ./Vol ;

% Add in boundary sink on diagonal of A.
A  = Ai - B ;

% Set up time vector and time increment.
times           = [0:10:500] ;           % Years.
initial_concs   = [3; 2; 1; 0.5; 0.5; 0.5; 0.1; 0.1; 0.1] ;
forcing_hi_lat  = 2.*ones(length(times),1) ;
forcing_mid_lat =    ones(length(times),1) ;
forcing         = [forcing_hi_lat';
                   forcing_mid_lat';
                   zeros(7,length(times))] ;
fprintf(1,' Computing solution from [%g] to [%g]yrs at [%d] intervals.\n',min(times),max(times),length(times)) ;
fprintf(1,' Initial condition:\n') ;
for box = 1:9
   fprintf(1,' Box [%d] = [%g] \n',box,initial_concs(box)) ;
end % box

% Find solution by calling box_model function.
fprintf(1,'\n\n Running box_model...') ;
tstart   = tic ;
concs    = box_model(initial_concs, times,forcing) ;
telapsed = toc(tstart) ;
fprintf(' done in [%g]s.\n\n',telapsed) ;

%% Figures
% Figure of box model flow
figure(1)
axes('Position',[0.3 0.3 0.5 0.5]) ;
box_edges = [ 0 3 3   0   0 1 1 2 2 3 3 0 0 3 3   0   0 3
              0 0 3.3 3.3 0 0 3 3 0 0 1 1 2 2 3.3 3.3 3 3] ;
loc = [ 0.8 1.8 2.8 0.8 1.8 2.8 0.8 1.8 2.8
        2.8 2.8 2.8 1.8 1.8 1.8 0.8 0.8 0.8 ] ;

% Start/end locations of arrows: row = start box, column = end box.
d2 = 0.35 ;
d3 = d2 ;
arrow_sx = [0    1    0    1-d3 0    0    0    0    0
            1    0    2    0    2-d2 0    0    0    0
            0    2    0    0    0    3-d2 0    0    0
            d2   0    0    0    1+d2 0    1-d2 0    0
            0    1+d3 0    1    0    2    0    2-d2 0
            0    0    0    0    2    2    0    0    3-d2
            0    0    0    d2   0    0    0    2    0
            0    0    0    0    1+d2 0    1    0    2
            0    0    0    0    0    2+d2 0    2    0 ] ;

arrow_sy = [0    3-d2 0    2    0    0    0    0    0
            2+d3 0    3-d2 0    2    0    0    0    0
            0    2    0    0    0    2    0    0    0
            2    0    0    0    2    0    1    0    0
            0    2    0    1+d2 0    1+d2 0    1    0
            0    0    0    2    1+d2 0    0    0    1
            0    0    0    1    0    0    0    d2   0
            0    0    0    0    1    0    d2   0    d2
            0    0    0    0    0    1    0    d2   0 ] ;

arrow_multx = [0    1    0    0    0    0    0    0    0
               -1   0    1    0    0    0    0    0    0
               0   -1    0    0    0    0    0    0    0
               0    0    0    0    1    0    0    0    0
               0    0    0   -1    0    1    0    0    0
               0    0    0    0   -1    0    0    0    0
               0    0    0    0    0    0    0    1    0
               0    0    0    0    0    0   -1    0    1
               0    0    0    0    0    0    0   -1    0 ] ;

arrow_multy = [0    0    0   -1    0    0    0    0    0
               0    0    0    0   -1    0    0    0    0
               0    0    0    0    0   -1    0    0    0
               1    0    0    0    0    0   -1    0    0
               0    1    0    0    0    0    0   -1    0
               0    0    1    0    0    0    0    0   -1
               0    0    0    1    0    0    0    0    0
               0    0    0    0    1    0    0    0    0
               0    0    0    0    0    1    0    0    0 ] ;
len1 = 7.00 ;
col = 'k' ;
theta = 20 ;

plot(box_edges(1,:), box_edges(2,:), 'k-') ;
hold on
set(gca,'box','off') ;
set(gca,'XtickLabel',[]) ;
set(gca,'YtickLabel',[]) ;
set(gca,'Xtick',[]) ;
set(gca,'Ytick',[]) ;
set(gca,'PlotBoxAspectRatio',[4/3 1 1]) ;
axis([ 0 3 0 3.3]) ;

for i = 1:9
   text(loc(1,i),loc(2,i),num2str(i), 'FontSize',12) ;
end

% Add circulation arrows
for i = 1:9
   for j = 1:9
      if(A(i,j) ~= 0 && i~=j )
        len = len1*A(i,j) ;
        tmp_s = [arrow_sx(i,j)+arrow_multx(i,j)*0.5*len arrow_sx(i,j)+arrow_multx(i,j)*0.4*len arrow_sx(i,j)-0.5*len*arrow_multx(i,j)
                 arrow_sy(i,j)+arrow_multy(i,j)*0.5*len arrow_sy(i,j)+arrow_multy(i,j)*0.4*len arrow_sy(i,j)-0.5*len*arrow_multy(i,j)] ;
        arrow_plot(theta,len*0.1,col,tmp_s(1,:),tmp_s(2,:),'k-','Linewidth',len*2) ;
        plot(tmp_s(1,:),tmp_s(2,:),'k-','Linewidth',len*2) ;
      end
   end
end

% Add Boundary conditions
bc_arrow = [d2 1-d2 1+d2 2-d2 2+d2 3-d2
            3  3    3    3    3    3    ] ;
for i = 1:4
        if(rem(i,2) == 0)
           len =  len1*m(ceil(i/2)) ;
        else
           len = -len1*m(ceil(i/2)) ;
        end
        tmp_s = [bc_arrow(1,i)              bc_arrow(1,i)              bc_arrow(1,i)
                 bc_arrow(2,i)+0.5*len bc_arrow(2,i)+0.4*len bc_arrow(2,i)-0.5*len] ;
        arrow_plot(theta,abs(len*0.1),col,tmp_s(1,:),tmp_s(2,:),'k-','Linewidth',abs(len*2)) ;
        plot(tmp_s(1,:),tmp_s(2,:),'k-','Linewidth',abs(len*2)) ;
end

% Annotate
h1(1)  = text(-0.2, 2.1,'Thermocline','fontsize',9) ;
h1(2)  = text(-0.2, 1.3,'Deep','fontsize',9) ;
h1(3)  = text(-0.2, 0.2,'Abyssal','fontsize',9) ;
h1(4)  = text( 3.2, 2.1,'Thermocline','fontsize',9) ;
h1(5)  = text( 3.2, 1.3,'Deep','fontsize',9) ;
h1(6)  = text( 3.2, 0.2,'Abyssal','fontsize',9) ;
h1(7)  = text( 0.2,-0.2,'High latitudes','fontsize',9) ;
h1(8)  = text( 1.2,-0.2,'Mid-latitudes','fontsize',9) ;
h1(9)  = text( 2.2,-0.2,'Low latitudes','fontsize',9) ;
h1(10) = text( 1.2, 3.5,'Troposphere','fontsize',9) ;
for i = 1:6
   set(h1(i),'rotation',90) ;
end
text(2.2,2.65,[num2str(S-d,'%3.0f'),'Sv'],'fontsize',9) ;
print -deps box_model_schematic.eps

% Figure of concentration results.
figure(2)
pos = [ 0.15 0.75 0.20 0.20
        0.40 0.75 0.20 0.20
        0.65 0.75 0.20 0.20
        0.15 0.50 0.20 0.20
        0.40 0.50 0.20 0.20
        0.65 0.50 0.20 0.20
        0.15 0.25 0.20 0.20
        0.40 0.25 0.20 0.20
        0.65 0.25 0.20 0.20 ] ;
lims = [min(times) max(times) min(concs(:)) max(concs(:))] ;

for i = 1:9 ;
   h(i) = axes('position',pos(i,:)) ;
   set(gca,'Fontsize',9) ;
   plot(times,concs(i,:),'-','linewidth',2) ;
   hold on
   text(lims(2)*0.85,lims(4)*0.3,num2str(i),'FontSize',12) ;
   axis(lims) ;
   if(rem(i,3)==0)
      set(gca,'YAxisLocation','right') ;
      ylabel('Concentration') ;
   elseif(rem(i,3)==2)
      set(gca,'YTickLabel',[]) ;
   else
      ylabel('Concentration') ;
   end
   if(i<7)
      set(gca,'XTickLabel',[]) ;
   else
      xlabel('Time (yrs)') ;
   end
end
subplot(h(2)) ;
title('Concentration solution') ;
print -deps box_model_soln.eps

% Figure of forcing.
figure(3)
pos = [ 0.15 0.75 0.20 0.20
        0.40 0.75 0.20 0.20
        0.65 0.75 0.20 0.20
        0.15 0.50 0.20 0.20
        0.40 0.50 0.20 0.20
        0.65 0.50 0.20 0.20
        0.15 0.25 0.20 0.20
        0.40 0.25 0.20 0.20
        0.65 0.25 0.20 0.20 ] ;
lims = [min(times) max(times) min(forcing(:)) max(forcing(:))] ;

for i = 1:9 ;
   h(i) = axes('position',pos(i,:)) ;
   set(gca,'Fontsize',9) ;
   plot(times,forcing(i,:),'-','linewidth',2) ;
   hold on
   text(lims(2)*0.85,lims(4)*0.3,num2str(i),'FontSize',12) ;
   axis(lims) ;
   if(rem(i,3)==0)
      set(gca,'YAxisLocation','right') ;
      ylabel('Concentration') ;
   elseif(rem(i,3)==2)
      set(gca,'YTickLabel',[]) ;
   else
      ylabel('Concentration') ;
   end
   if(i<7)
      set(gca,'XTickLabel',[]) ;
   else
      xlabel('Time (yrs)') ;
   end
end
subplot(h(2)) ;
title('Forcing data') ;
