function signchanges = give_sign_changes(list_in)
    A = list_in;
    A(A>0)=1;
    A(A<0)=0;
    signchanges =find(diff(A)~=0&~isnan(A(1:end-1))&~isnan(A(2:end)));
%     signchanges(isnan(list_in)) = nan;