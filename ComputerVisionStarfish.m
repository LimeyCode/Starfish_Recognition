clc;	% Clear command window.
clear;	% Delete all variables.

%get Image needed
InputImage = imread("starfish_5.jpg");

%plot original image
firstFigure = figure;
subplot(3,4,1);
imshow(InputImage);
title('Original');

%get histogram of Input Image
[pixelCount, grayLevels] = imhist(InputImage);
subplot(3, 4, 6);
bar(pixelCount);
title('Histogram of Input Image');
xlim([0 grayLevels(end)]);
grid on;

%Get HSV image
hsvImage = rgb2hsv(InputImage);

% Extract out the H, S, and V images individually
hImage = hsvImage(:,:,1);
sImage = hsvImage(:,:,2);
vImage = hsvImage(:,:,3);


%Reduce the noise
reduceNoiseImage = medfilt2(sImage);
sImage = wiener2(reduceNoiseImage,[6,7]);

%Threshold Image method 1
%=================================================================================
%normalizedThresholdValue = 0.9; % In range 0 to 1.
%thresholdValue = normalizedThresholdValue * max(max(reduceNoiseImage)); % Gray Levels.
%binaryImage = imbinarize(reduceNoiseImage, normalizedThresholdValue);
%=================================================================================

%Threshold method 2
hSaturationPlot = subplot(3, 4, 7); 
[saturationCounts, saturationBinValues] = imhist(sImage); 
maxSaturationBinValue = find(saturationCounts > 0, 1, 'last'); 
maxCountSaturation = max(saturationCounts); 
area(saturationBinValues, saturationCounts, 'FaceColor', 'g'); 
grid on; 
xlabel('Saturation Value'); 
ylabel('Pixel Count'); 
title('Histogram of Saturation Image', 'FontSize', 12);
saturationThresholdLow = graythresh(sImage);
saturationThresholdHigh = 1.0;
PlaceThresholdBars(7, saturationThresholdLow, saturationThresholdHigh);
saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
subplot(3, 4, 10);
imshow(saturationMask, []);
title('&   Saturation Mask', 'FontSize', 12);
subplot(3,4,11);
imshow(reduceNoiseImage);
title("reduced noise");

%fill holes
binaryImage = imfill(saturationMask, 'holes');

% Display the hue image.
subplot(3, 4, 2);
h1 = imshow(hImage);
title('Hue Image');

% Display the saturation image.
h2 = subplot(3, 4, 3);
imshow(sImage);
title('Saturation Image');

% Display the value image.
h3 = subplot(3, 4, 4);
imshow(vImage);
title('Value Image');

%show binary image
subplot (3,4,5);
imshow(binaryImage);
title('Binary Image');

%remove small objects
binaryImage = bwareaopen(binaryImage, 400);

%label all connected pixels and display new image
labeledImage = bwlabel(binaryImage, 8);
subplot (3,4,8);
imshow(labeledImage, []);
title('Labeled Image');

%coloured labels
coloredLabels = label2rgb (labeledImage, 'hsv', 'k', 'shuffle');
subplot(3, 4, 9);
imshow(coloredLabels);
title('Colour Labeled Image');

%Morphology techniques
%se90 = strel('line',3,90);
%se0 = strel('line',3,0);
%BWsdil = imdilate(binaryImage,[se90 se0]);
%subplot(3,4,10);
%imshow(BWsdil)
%title('Dilated Gradient Mask')

%Smooth Objects
seD = strel('diamond',1);
%seD = strel('line',3,90);
%se = strel('line',3,270);
BWfinal = imclose(binaryImage,seD);
%BWfinal = imerode(BWclose,se);
[labeledImage, numberOfObjcts] = bwlabel(BWfinal);
subplot (3,4,11);
imshow(BWfinal)
title('Segmented Image');


blobMeasurements = regionprops(BWfinal, 'all');
properties_table = regionprops('table', BWfinal, 'all');


figure
for blobNumber = 1 : numberOfObjcts 
    
        %Find the bounding box of each blob.
		thisBlobsBoundingBox = blobMeasurements(blobNumber).BoundingBox; 
        Area = blobMeasurements(blobNumber).Area;
        Perimeter = blobMeasurements(blobNumber).Perimeter;
        MinorAxis = blobMeasurements(blobNumber).MinorAxisLength;
        MajorAxis = blobMeasurements(blobNumber).MajorAxisLength;
        ConvexArea = blobMeasurements(blobNumber).ConvexArea;
        MaxFeretDiameter = blobMeasurements(blobNumber).MaxFeretDiameter;
        MinFeretDiameter = blobMeasurements(blobNumber).MinFeretDiameter;
        ConAreaRatio = ConvexArea/Area;
        AxisRatio = MajorAxis/MinorAxis;
        PermAreaRatio = Perimeter/Area;
        AreaMajorR = Area/MajorAxis; 
        MinMaxR = MinFeretDiameter/MaxFeretDiameter;
		subImage = imcrop(InputImage, thisBlobsBoundingBox);
		if (ConAreaRatio > 1.674 && ConAreaRatio < 2.288) && (AxisRatio > 1.046 && AxisRatio < 1.496) && (PermAreaRatio > 0.17 && PermAreaRatio < 0.253) && (AreaMajorR > 17.6 && AreaMajorR < 25.4)
			objectType = 'StarFish';
		else
			objectType = 'not StarFish';
		end
		% Display the image with caption.
		subplot(3, 6, blobNumber);
		imshow(subImage);
		caption = sprintf('Object #%d is a %s\n',blobNumber, objectType);
		title(caption, 'FontSize', 12);
end


figure(firstFigure)
subplot(3,4,12)
imshow( InputImage )
count = 0;
hold on
for blobNumber = 1 : numberOfObjcts 
 
        Area = blobMeasurements(blobNumber).Area;
        Perimeter = blobMeasurements(blobNumber).Perimeter;
        MinorAxis = blobMeasurements(blobNumber).MinorAxisLength;
        MajorAxis = blobMeasurements(blobNumber).MajorAxisLength;
        ConvexArea = blobMeasurements(blobNumber).ConvexArea;
        ConAreaRatio = ConvexArea/Area;
        AxisRatio = MajorAxis/MinorAxis;
        PermAreaRatio = Perimeter/Area;
        AreaMajorR = Area/MajorAxis;
        
		if (ConAreaRatio > 1.674 && ConAreaRatio < 2.288) && (AxisRatio > 1.046 && AxisRatio < 1.496) && (PermAreaRatio > 0.17 && PermAreaRatio < 0.253) && (AreaMajorR > 17.6 && AreaMajorR < 25.4)
            mask = false(size(BWfinal));
            x = round( blobMeasurements(blobNumber).BoundingBox(1) );
            y = round( blobMeasurements(blobNumber).BoundingBox(2) );
            xmax = x + round( blobMeasurements(blobNumber).BoundingBox(3) );
            ymax = y + round( blobMeasurements(blobNumber).BoundingBox(4) );
            mask(y: ymax, x: xmax) = true;
            visboundaries(mask,'Color','r'); 
            count = count + 1;
            
        end
        captionTwo = sprintf('Number of starfish is %d',count);
		title(captionTwo, 'FontSize', 11);
		
end
hold off;

function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
try
	
	subplot(3, 4, plotNumber); 
	hold on;
	yLimits = ylim;
	line([lowThresh, lowThresh], yLimits, 'Color', 'r', 'LineWidth', 3);
	line([highThresh, highThresh], yLimits, 'Color', 'r', 'LineWidth', 3);
	fontSizeThresh = 14;
	annotationTextL = sprintf('%d', lowThresh);
	annotationTextH = sprintf('%d', highThresh);
	text(double(lowThresh + 5), double(0.85 * yLimits(2)), annotationTextL, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	text(double(highThresh + 5), double(0.85 * yLimits(2)), annotationTextH, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	
	
catch ME
	errorMessage = sprintf('Error in function %s() at line %d.\n\nError Message:\n%s', ...
		ME.stack(1).name, ME.stack(1).line, ME.message);
	fprintf(1, '%s\n', errorMessage);
	uiwait(warndlg(errorMessage));
end
return; 
end
