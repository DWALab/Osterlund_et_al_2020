function  bound_fraction  = GetBoundFractionVectorSpace(z,z1,z2)
%%% Function used to determine the fractional distance between two points in space
%%% It is used to calculate the bound fraction between the phasor coordinates of bound and unbound lifetimes
    p1 = z-z2;
    p2 = conj(z1-z2); 
    p3 = z1 -z2; 
    bound_fraction = dot(p1,p2/(norm(p3) * norm(p3)));
end