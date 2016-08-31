indir = 'sean sumo';
outdir = 'sean sumo out';

if ~exist(outdir)
    mkdir(outdir);
end

files = dir(sprintf('%s/*.mat',indir));

for i=1:length(files)
   load(fullfile('sean sumo', files(i).name));
   img_scaled = double(img)/10 - 273.15;
   dlmwrite(sprintf('%s/%s.csv',outdir,files(i).name),img_scaled);
   
   imagesc(img_scaled,[0,40]); colorbar;
   
   fig = gcf;
   print(fig, sprintf('%s/%s.png',outdir,files(i).name),'-dpng');
   
   i
end