function J = dos_non_local_means(I,K,S,var,h)
%DOS_NON_LOCAL_MEANS je funkcija kojom se realizuje ne-lokalno usrednjavanje
%slike.
%
%J=DOS_NON_LOCAL_MEANS(I,K,S,var,h)
%Slicnost izmedju piksela se proverava nad prozorima dimenzije KxK u
%okolini piksela, dok se potencijalni kandidati za usrednjavanje 
%pretrazuju u okviru oblasti dimenzija SxS. Procenjena varijansa suma se 
%zadaje kao parametar var, dok parametar h prestavlja jacinu odsumljivanja
%
%Ulazni argumenti:
%-------------------
%I    -ulazna slika
%K    -velicina prozora nad kojom se proverava slicnost
%S    -prozor u okviru koga se nalaze kandidati za usrednjavanje
%var  - procenjena varijansa slike
%h    -jacina odsumnjivanja
%
%Primer:
%-------------------
%I = im2double(imread('lena_noise.tif'));
%K = 5;
%S = 33;
%var = 0.007;
%h = 0.05;
%J = dos_non_local_means(I,K,S,var,h);  
%figure; imshow(J);
%
[M, N] = size(I);
half_S = floor((S-1)/2);
half_K = floor((K-1)/2);
% prosirivanje originalne slike za (K_pola + S_pola) sa svake strane
I_padded = padarray(I,[half_S+half_K, half_S+half_K],'symmetric');
J = zeros(size(I)); % izlazna slika
for i=half_S+half_K+1:M+half_S+half_K % ove 2 for petlje sluze za prolazak kroz svaki piksel matrice I
    for j=half_S+half_K+1:N+half_S+half_K
        % kreiranje matrice matrice S oko trenutno piksela I(i,j)
        % matrica S je prosirena sa svake strane sa K_pola da bismo mogli
        % da nadjemo okolinu KxK piksela na ivicama matrice S
        Smatrix = I_padded(i-half_S-half_K:i+half_S+half_K, j-half_S-half_K:j+half_S+half_K); 
        middle = S + half_K;
        % kreiranje prozora KxK oko glavnog piksela
        Bp = Smatrix(middle-half_K:middle+half_K, middle-half_K:middle+half_K);
        weightedSum = 0;
        sumOfWeights = 0;
        for m = half_K+1:S+half_K % ove dve for petlje sluze za prolazak kroz svaki piksel matrice S
            for n = half_K+1:S+half_K
                % kreiranje prozora KxK oko piksela matrice S, kojeg trenutno
                % obradjujemo
                Bq = Smatrix(m-half_K:m+half_K, n-half_K:n+half_K);
                norm = (Bp-Bq).^2;
                norm = sum(norm(:))/K^2;
                currentWeight = exp(-max(norm-2*var,0)/h^2);
                sumOfWeights = sumOfWeights + currentWeight; 
                weightedSum = weightedSum + currentWeight*Smatrix(m,n);
            end
        end
        J(i-half_S-half_K, j-half_S-half_K) = weightedSum/sumOfWeights;
    end
end
end