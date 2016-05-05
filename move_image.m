function output = move_image( img,movement)
    pad = ceil(max(abs(movement)));
    [hh,ww,c] = size(img);
    I = single(zeros(hh+pad*2,ww+pad*2,c)); %produce a bigger image
    I (pad:hh+pad-1,pad:ww+pad-1,:) = img;
    x = hh/2 + pad - movement(2);
    y = ww/2 + pad - movement(1);
    output = I(round(x-hh/2+1):round(x+hh/2)...
        ,round(y-ww/2+1):round(y+ww/2),:);
end

