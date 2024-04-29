% Autor: Guillermo Fernando Regodón Harkness
% Github: https://github.com/GuillermoRegodon/matlab-class-fftreal.git

% Clase de Matlab para crear objetos que permiten estudiar el efecto de la
% distorsión lineal y no lineal en un sistema de transmisión. Está
% construida para simplificar el manejo del vector/array f = fft(x) que en
% general es de números complejos. Si x es real, f(i) = (f(-i))*, es decir,
% la parte negativa es el complejo conjugado de la positiva. Con Fftreal,
% x siempre es real.

% Los objetos son una estructura de datos más las funciones permitidas.
% En Matlab, significa que tenemos que devolver siempre la estructura y
% guardarla. Si no, la computación se pierde (aunque otros efectos, como 
% plot sí puedan ser observables)

% En el fichero Fftreal_ejemplos.m y .mlx hay ejemplos de cada función.
% Aquí están los mismos ejemplos en comentarios (por lo que copiar/pegar
% se hace más incómodo). En dicho fichero, además está el Problema 4 del
% Boletín 2 resuelto.
%% CLASE
classdef Fftreal
    %% Estructura de datos que usa el cada objeto
    properties
        x   % función temporal. La intención es que sea real
        f   % tranformada de Fourier
        f0  % valor de f para frecuencia 0
        N   % longitud de f (importante para ajustar la mitad f negativa) 
    end

    %% Funciones permitidas
    methods
        %% Constructor:
        % Se usa a partir de un array temporal o de un array en frecuencia
        function obj = Fftreal(x, f)
            if nargin == 0
                obj.x = [];
                obj.f = [];
                obj.f0 = [];
                obj.N = 0;
            elseif nargin == 1
                obj = obj.fft(x);
            elseif nargin == 2
                obj.f = f;
                obj.f0 = 0;
                obj.N = 2*length(f);
                obj = obj.ifft();     % x es real
            end
        end
        % % PRIMER USO:
        % % Creamos un array con una señal cuadrada de ejemplo
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % 
        % % Creamos un objeto para estudiar la señal cuadrada
        % fft_cuad = Fftreal(x);
        % fft_cuad.plotx();
        % 
        % % SEGUNDO USO:
        % % Creamos un array de frecuencias con tres armónicos de ejemplo
        % f = [zeros(1, 4000)];
        % f(3) = 15;
        % f(9) = 5;
        % f(15) = 3;
        % 
        % % Creamos un objeto para estudiar la señal de los tres armónicos
        % fft_armo = Fftreal([], f);
        % fft_armo.plotx();

        %% FFT:
        % Construye la fft. Se usa en el constructor
        function obj = fft(obj, x)
            obj.x = x;
            obj.f = fft(x);
            obj.f0 = obj.f(1);
            obj.f = obj.f(2:floor(length(obj.f)/2+1));
            obj.N = length(x);
        end

        %% IFFT:
        % Calcula el array temporal a partir de la fft. x siempre es real.
        % Se usa en el constructor
        function obj = ifft(obj)
            f_t = [obj.f0 obj.f flip(conj(obj.f(1:end-1+(mod(obj.N, 2)))))];
            obj.x = real(ifft(f_t));
        end

        %% ARRAY DE FRECUENCIAS
        % Devuelve el array de frecuencias w que se puede usar para las
        % funciones de betal, alfa y veloc.
        function freq = freq(obj)
            freq = linspace(0,1,length(obj.f)+1);
            freq = freq(2:end);
        end

        %% FUNCIONES DE PLOT
        % Para ilustrar los array temporales y espaciales.
        %   -plotx pinta el array temporal.
        %   -plotabsf pinta el módulo de la FFT
        %   -plotf pinta módulo y fase de la FFT con dos ejes y
        % Las funciones acabadas en una f adicional pintan la misma figura
        % en una nueva ventana, para conservar las figuras anteriores:
        %   -plotxf, plotabsff y plotff
        function plotx(obj)
            plot(obj.x);
        end
        function plotxf(obj)
            figure;
            plotx(obj);
        end
        function plotabsf(obj)
            plot(abs(obj.f));
        end
        function plotabsff(obj)
            figure;
            plotabsf(obj);
        end
        function plotf(obj)
            yyaxis left;
            plot(abs(obj.f));
            yyaxis right;
            plot(angle(obj.f));
        end
        function plotff(obj)
            figure;
            plotf(obj);
        end


        %% DELAY
        % retrasa matemáticamente cada componente de frecuencia en un
        % valor correspondiente
        function obj = delay(obj, d)
            obj.f = (obj.f).*exp(-1i*pi*d.*(1:length(obj.f))/length(obj.f));
            obj = obj.ifft();
        end
        % % PRIMER USO, todas las frecuencias se retrasan igual
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % d = 100;
        % fftn = fft.delay(d);
        % fft.plotx
        % hold on
        % fftn.plotx
        % hold off
        % 
        % % SEGUNDO USO, algunas frecuencias se retrasan más que otras
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % d = 100*ones(size(fft.freq()));
        % d(3) = 200;
        % fftn = fft.delay(d);
        % fft.plotx; hold on
        % fftn.plotx; hold off


        %% BETA:
        % función que muestra el efecto de beta. Para que no haya
        % distorsión, beta debe ser lineal con w = obj.freq()
        %   -betal propaga la señal con una beta una distancia l
        %   -betalp hace lo mismo y además pinta la señal resultante.
        function obj = betalp(obj, beta, l)
            obj = obj.betal(beta, l);
            obj.plotx();
        end
        function obj = betal(obj, beta, l)
            obj.f = (obj.f).*exp(-1i*pi*beta*l);
            obj = obj.ifft();
        end
        % %% BETA
        % % PRIMER USO, sin distorsión de fase.
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % beta = fft.freq()*10;
        % l = 50;
        % fftn = fft.betal(beta, l);
        % fft.plotx; hold on
        % fftn.plotx; hold off
        % 
        % % SEGUNDO USO, con distorsión de fase, frecuencia de corte 0.0015
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % freq = fft.freq();
        % beta = sqrt(freq(3)^2 + freq.^2)*10;
        % l = 50;
        % fftn = fft.betal(beta, l);
        % fft.plotx; hold on
        % fftn.plotx; hold off


        %% ALFA:
        % función que muestra el efecto de alfa. Para que no haya
        % distorsión, alfa tiene que ser constante, en cuyo caso, la señal
        % se atenuará con la misma forma.
        %   -alfa atenua una distancia l
        %   -alfap hace lo mismo y además pinta la señal resultante.
        function obj = alfap(obj, alfa, l)
            obj = obj.alfa(alfa,l );
            obj.plotx();
        end
        function obj = alfa(obj, alfa, l)
            obj.f = (obj.f).*exp(-alfa*l);
            obj = obj.ifft();
        end
        % % PRIMER USO, sin distorsión de amplitud.
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % alfa = 0.02;
        % l = 50;
        % fftn = fft.alfa(alfa, l);
        % fft.plotx; hold on
        % fftn.plotx; hold off
        % 
        % % SEGUNDO USO, con distorsión de fase, frecuencia de corte 10
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % freq = fft.freq();
        % alfa = freq*2;
        % l = 50;
        % fftn = fft.alfa(alfa, l);
        % fft.plotx; hold on
        % fftn.plotx; hold off


        %% VELOC
        % Función para estudiar el efecto de las distintas velocidades para
        % distintas frecuencias. Para que no haya distorsión, la velocidad
        % debe de ser constante para todas las frecuencias.
        %   -veloc propaga la función una distancia l
        %   -velocp hace lo mismo y además pinta la señal resultante.
        function obj = velocp(obj, veloc, l)
            beta = obj.freq*obj.N./veloc;
            obj = obj.betalp(beta, l);
        end
        function obj = veloc(obj, veloc, l)
            beta = obj.freq*obj.N./veloc;
            obj = obj.betal(beta, l);
        end
        % % PRIMER USO, sin distorsión de fase.
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % veloc = 1000;
        % l = 50;
        % fftn = fft.veloc(veloc, l);
        % fft.plotx; hold on
        % fftn.plotx; hold off
        % 
        % % SEGUNDO USO, con distorsión de fase, frecuencia de corte 0.0015
        % x = [zeros(1, 1000), ones(1, 2000), zeros(1,1000)];
        % fft = Fftreal(x);
        % freq = fft.freq();
        % veloc = 1000*freq./sqrt(freq(3)^2 + freq.^2);
        % l = 50;
        % fftn = fft.veloc(veloc, l);
        % fft.plotx; hold on
        % fftn.plotx; hold off

    end
end