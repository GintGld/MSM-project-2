function Circuit = dist_rec(Circuit,i,j,d)

d = d + 1;

if Circuit(i,j) == -1 || Circuit(i,j) > d;
    Circuit(i,j) = d;

    for di = -1 : 1
        for dj = -1 : 1
            if di ~= 0 || dj ~= 0
                Circuit = dist_rec(Circuit,i+di,j+dj,d);
            end
        end
    end
end

