% clear all;
% test

%%- parameters
Fe              = 2048;
tMax            = 0.5;
pseudo_f_min    = 2;
pseudo_f_max    = 1000;
pseudo_f_step   = 5;
wname1          = 'cmor1-1.5';

%%-
t       = linspace(0,tMax,tMax*Fe);
x       = 2*sin(2*pi*200*t)+sin(2*pi*20*t);

%- Wavelet 'Complex Morlet'
pseudofreq      = pseudo_f_min:pseudo_f_step:pseudo_f_max;
wave_fc         = centfrq (wname1);
scales          = wave_fc*Fe./pseudofreq;
coeffs          = cwt(x,scales,wname1);
S               = abs(coeffs.*coeffs);

%- Morse Wavelet
nk  = 4;
A=(1:30).*0.6;
scales2        = 0.3*Fe./pseudofreq;
morseScalogram = zeros(length(pseudofreq),length(t),nk);
for k=0:nk-1
    morseScalogram(:,:,k+1)=wscal55b(x,scales2,8,3,k,1);
end
S2 = mean(abs(morseScalogram).^2,3);

figure;
ax(1) = subplot(311); 
plot(t,x);
ax(2) = subplot(312); 
imagesc(S,'XData',t,'HitTest','off');  
axis('xy','tight');
% ylims   = ylim;
% offset  = 0.5*diff(ylim)/length(scales);   
% ytick_label = round(linspace(pseudofreq(1),pseudofreq(end),10));
% Overlay horizontal lines
% set (gca,'ygrid','on','xgrid','on','XColor',vi_graphics('tf_grid_color'),'YColor',vi_graphics('tf_grid_color'));
% set (gca,'YTick',linspace(offset+ylims(1),offset+ylims(2),10),'YTickLabel',ytick_label); 
ax(3) = subplot(313);
imagesc(S2); axis('xy','tight');