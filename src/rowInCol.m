function row = rowInCol(layout, block, col)
%Check if block is in column col of layout. If it is then return the row,
%else return 0.

row = 0;
try %error if col is out of bounds
    for k = 1:layout.colLengths(col)
        if strcmp(layout.grid{k,col}.fullname, block)
            row = k;
        end
    end
end
end