%%%%%%% DINÁMICA MOLECULAR

clear, clc, close all


% Seleccionar si se crea una nueva simulación o se retoma una ya guardada.
simulacionElegida = menu('Seleccione modo de simulación:', 'Nueva simulación', 'Retomar simulación existente');
if simulacionElegida == 1
    nuevaSim = true;
else
    nuevaSim = false;
end

% Menú para elegir visualización: imágenes y gráficas, sólo gráficas, sólo imágenes o nada
plotChoice = menu('Seleccione tipo de visualización:', 'Imágenes y gráficas', 'Sólo gráficas', 'Sólo imágenes', 'Sin plotting');


n = 85;                    % Número de partículas por arista
N = n^3;                   % Número de partículas total
dens = 1680;
A = 0.039948;
m = A/(6.022e23);
To = 120;                  % Temperatura en Kelvin
L = ((N*m)/dens)^(1/3);
V = L^3;
kB = 1.3806e-23;

dt = 1e-14;

% Adimensionalización de las ecuaciones
e = kB*To;
Toa = To/120;
s = 3.4e-10;
La = L/s;
rc = La/2;
dta = dt*sqrt(e/(m*s^2));

% Si se inicia una simulación
if nuevaSim

    t0 = 1;
    % Ubicamos las partículas en las aristas del cubo

    x = linspace(0,La,n);
    y = x;
    z = x;

    pos = [];

    for i = 1:n
        for j = 1:n
            for k = 1:n
                if (i==1 && j == 1) || (i==n && j==n) || (i==1 && k==1) || (i==n && k==n) || (j==1 && k==1) || (j==n && k==n) || (i==1 && j == n) || (i==n && j==1) || (i==1 && k==n) || (i==n && k==1) || (j==1 && k==n) || (j==n && k==1)
                    pos = [pos; [x(i),y(j),z(k)]];
                end
            end
        end
    end

    figure;
    plot3(pos(:,1),pos(:,2),pos(:,3),'r+')
    xlabel("X")
    ylabel("Y")
    zlabel("Z")

    clear x y z

    posinic = pos;

    saveas(gcf,"posicioninicial","png")
    % Actualizamos el número de partículas (obtenemos sólo las ubicadas en las
    % aristas

    N = length(pos);

    % Inicializamos la velocidad inicial

    v = rand(N,3)-0.5;

    % Le restamos la velocidad del centro de masas

    v = v - (1/N)*sum(v,1);


    % Aplicamos el factor de escala a las velocidades

    % FS = sqrt( (3*Toa) / ( (1/N) )*sum(vecnorm(v,2,1).^2) );
    %
    % v = v*FS;


    % Cálculo de la aceleración para cada partícula

    a = zeros(N,3);

else
    % Proseguimos la simulación desde archivo "simulation.mat"
    if exist('simulation.mat','file')
        load('simulation.mat', 'simulation');
        pos = simulation.pos;
        v   = simulation.v;
        t0  = simulation.t0;
        Ek  = simulation.Ek;
        U   = simulation.U;
        T   = simulation.T;
        Vcm = simulation.Vcm;
        P = simulation.P;
        pares = simulation.pares;
        posinic = simulation.posinic;
        N = size(pos,1);
    else
        error('No se encontró el archivo simulation.mat. Inicie una nueva simulación.');
    end
end

imagenes = [ 0 0 0; 1 1 1; -1 -1 -1; 0 1 0; 0 0 1; 1 0 0; 0 1 1; 1 0 1; 1 1 0; 0 -1 0; 0 0 -1 ; -1 0 0; 0 -1 -1; -1 0 -1; -1 -1 0; 1 -1 1; 1 1 -1; -1 1 1; 1 -1 -1; -1 1 -1; -1 -1 1; -1 1 0; 0 -1 1; 1 0 -1; 1 -1 0; 0 1 -1; -1 0 1] * La;

% Mostramos las figuras deseadas
if plotChoice == 1 || plotChoice == 3
    f1 = figure("Name","Partículas","NumberTitle","off");
end
if plotChoice == 1 || plotChoice == 2
    f2 = figure("Name","Medidas1","NumberTitle","off");
    f3 = figure("Name","Medidas2","NumberTitle","off");
end


niter = 101;


for t = t0 : t0+niter
    disp(t)
    % Cálculo de la aceleración inicial
    a = zeros(N,3);
    suma = 0;

    for i = 1:N-1 % Se recorre cada par de partículas con i<j
        for j = i+1:N
            r = pos(i,:) - pos(j,:);

            % Buscamos la imagen que interactúa con la partícula

            r(1) = r(1) - La*round(r(1)/La);
            r(2) = r(2) - La*round(r(2)/La);
            r(3) = r(3) - La*round(r(3)/La);

            dist = norm(r);

            % Añadimos una distancia máxima entre partículas, cortando los valores altos del potencial
            if dist < rc
                if dist < 0.9
                    dist = 0.9;
                end

                % Calculamos la aceleración
                ac = 48*((1/dist)^14 - (1/dist)^8) * r;

                % Aplicamos la fuerza a ambas partículas
                a(i,:) = a(i,:) + ac;
                a(j,:) = a(j,:) - ac;

                % Acumulamos el potencial, para su posterior uso
                suma = suma + ((1/dist)^12 - 0.5*(1/dist)^6);
            end
        end
    end


    for i = 1:N
        for dim = 1:3
            aux = v(i,dim) + (dta/2) * a(i,dim);
            post(i,dim) = pos(i,dim) + dta * aux;
            v(i,dim) = aux + (dta/2) * a(i,dim);
        end
    end

    % Filtrado de partículas que escaparon de la caja (condición de periodicidad)
    for i = 1:N
        for dim = 1:3
            if post(i,dim) > La || post(i,dim) < 0
                post(i,dim) = La - pos(i,dim);
            end
        end
    end
    pos = post;

    %%%%%%%%%%%%%%%% MEDIDAS Y ERRORES

    % Energías
    Ek(t) = 0.5*(sum(vecnorm(v,2,2).^2));
    % La energía potencial se calcula junto a la aceleración
    pares(t) = suma;
    U(t) = 4*suma;

    % Temperatura
    T(t) = ( 1/(3*N) )*(sum(vecnorm(v,2,2).^2));

    % Velocidad del centro de masas
    Vcm(t) = (1/N)*vecnorm(sum(v,1),2);

    % Calculamos la presión
    dim = 3;
    P(t) = ((N * mean(T)) + (48/dim) * (mean(pares))) / La^3;

    if mod(t,250) == 0
        figure;
        plot3(post(:,1),post(:,2),post(:,3),'r.')
        xlabel("X")
        ylabel("Y")
        zlabel("Z")
        title(sprintf("Posiciones de las partículas para el instante t = %d",t));
        saveas(gcf,sprintf("posiciont=%d",t),'png');
        close(gcf);
    end

    % Presentamos las imágenes y/o las gráficas si se ha elegido
    if plotChoice == 1 || plotChoice == 3   % Imágenes
        figure(f1)
        plot3(posinic(:,1),posinic(:,2),posinic(:,3),'r.')
        hold on
        % quiver3(post(:,1),post(:,2),post(:,3),v(:,1),v(:,2),v(:,3),5)
        plot3(post(:,1),post(:,2),post(:,3),'b.')
        xlabel("X")
        ylabel("Y")
        zlabel("Z")
        hold off
    end

    if plotChoice == 1 || plotChoice == 2  % Gráficas
        tiempo = 1:t;
        figure(f2)
        hold on
        subplot(6,3,1:6)
        plot(tiempo,Ek+U)
        xlabel("t*")
        ylabel("(Ek*+U*)")
        title("Energía total")
        subplot(6,3,7:12)
        plot(tiempo,U)
        xlabel("t*")
        ylabel("U*")
        title("Energía potencial")
        subplot(6,3,13:18)
        plot(tiempo,Ek)
        xlabel("t*")
        ylabel("Ek*")
        figure(f3)
        title("Energía cinética")
        subplot(6,3,1:6)
        plot(tiempo,T)
        xlabel("t*")
        ylabel("T*")
        title("Temperatura")
        subplot(6,3,7:12)
        plot(tiempo,Vcm)
        xlabel("t*")
        ylabel("v_{CM}")
        title("Velocidad del centro de masas")
        subplot(6,3,13:18)
        plot(tiempo,P)
        xlabel("t*")
        ylabel("P*")
        title("Presión")
        hold off
    end

    % Guardamos los datos en el archivo (archivo "simulation.mat")
    simulation.pos = pos;
    simulation.v = v;
    simulation.t0 = t+1;   % La siguiente iteración a retomar
    simulation.Ek = Ek;
    simulation.U = U;
    simulation.T = T;
    simulation.P = P;
    simulation.Vcm = Vcm;
    simulation.pares = pares;
    simulation.posinic = posinic;
    save('simulation.mat', 'simulation');

end

% Tratamiento de errores

analisisPorBloques(Ek,'Ek^*','Ek')
analisisPorBloques(U,'U^*','U')
analisisPorBloques(Ek+U,'(Ek+U)^*','Ek+U')
analisisPorBloques(T,'T^*','T')
analisisPorBloques(P,'P^*','P')




function [bsize, varianza, bnum] = analisisPorBloques(A, variable_name, variable_name2)
% Entrada:
%   A: vector columna o fila de M medidas de una magnitud observada.
%   variable_name: string con el nombre de la magnitud (para el título de la gráfica).
%   variable_name2: string para el nombre del archivo de la figura.
% Salida:
%   bsize: tamaños de bloque.
%   varianza: varianza estimada para los tamaños de bloque.
%   bnum: número de bloques.

    A = A(:);
    M = length(A);

    bsize = 2.^(0:floor(log2(M/4)));       % se calcula el tamaño de los bloques
    bnum = floor(M ./ bsize);
    varianza = zeros(size(bsize));  % se inicializa la varianza

    for i = 1:length(bsize)
        b = bsize(i);
        Mb = bnum(i);
        bmedio = zeros(Mb, 1);

        for j = 1:Mb
            bmedio(j) = mean(A((j-1)*b + 1 : j*b));
        end

        varianza(i) = var(bmedio, 1);
    end

    % === Gráfica ===
    figure;
    loglog(bnum, varianza, 'rs-');
    xlabel("Número de bloques (b)")
    ylabel("{\sigma}^2")
    title("Varianza para",inputname(1))
    grid on;

    % Crear carpeta si no existe
    if ~exist('Fotos', 'dir')
        mkdir('Fotos');
    end
    saveas(gcf, fullfile('Fotos', ['varianza_', variable_name2, '.png']));

    % === Tabla de varianzas ===
    fprintf('\n===== Tabla de varianzas =====\n');
    fprintf('%-20s %-20s %-20s\n', 'Tamaño del bloque', 'Nº de bloques', 'Varianza estimada');
    fprintf('%-20s %-20s %-20s\n', repmat('-',1,20), repmat('-',1,20), repmat('-',1,20));
    for i = 1:length(bsize)
        fprintf('%-20d %-20d %-20.6e\n', bsize(i), bnum(i), varianza(i));
    end

    % === Tabla de desviaciones estándar ===
    fprintf('\n===== Tabla de desviaciones estándar =====\n');
    fprintf('%-20s %-20s %-20s\n', 'Tamaño del bloque', 'Nº de bloques', 'Desv. estándar');
    fprintf('%-20s %-20s %-20s\n', repmat('-',1,20), repmat('-',1,20), repmat('-',1,20));
    for i = 1:length(bsize)
        fprintf('%-20d %-20d %-20.6e\n', bsize(i), bnum(i), sqrt(varianza(i)));
    end
end
