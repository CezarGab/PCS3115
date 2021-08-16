library ieee;
use ieee.numeric_bit.all;

entity jkpn is
    port(
        reset, clock:       in bit;
        inicia, carrega:    in bit;
        nJogos:             in bit_vector(3 downto 0);
        gestoA, gestoB:     in bit_vector(1 downto 0);
        zRodada, zMatch:    out bit_vector(1 downto 0);
        jogosRestantes:     out bit_vector(3 downto 0);
        placarA, placarB:   out bit_vector(3 downto 0)
    );
end jkpn;

architecture jkpn_arch of jkpn is

    component jokempo 
        port(
        a: in bit_vector(1 downto 0); 
        b: in bit_vector(1 downto 0); 
        y: out bit_vector(1 downto 0) 
        );
    end component;
  
    component contador
        port(
        clock, reset: in bit;
        count:        in bit;
        parallel_out: out bit_vector(3 downto 0)

        );
    end component;

    component registrador
        port (
            clock, reset: in bit; 
            load:         in bit; 
            addValue:     in bit_vector(3 downto 0);   
            parallel_out: out bit_vector(3 downto 0)
        );
    end component; 

    component decreaser
        port (
            clock, reset: in bit; -- Reset assincrono
            load:         in bit; -- Carrega o valor
            addValue:     in bit_vector(3 downto 0); -- Carrega o valor no registrador
            decrease:        in bit; -- Decrementa a contagem
            parallel_out: out bit_vector(3 downto 0) -- Conteudo do contador
        );
    end component;

    type state_type is (zero, inicio, roundsEmExecucao, vitoriaA, vitoriaB);
    signal state, next_state: state_type;
    signal aGanhou, bGanhou, gestosEmEspera, loadNJogos: bit;
    signal bit_placarA, bit_placarB, bit_jogosRestantes: bit_vector(3 downto 0);
    signal nJogosRegistrado: bit_vector(3 downto 0);
    signal bit_zRodada:      bit_vector(1 downto 0);
    signal aGanhaMatch, bGanhaMatch: bit;

    signal estadoAtual: bit_vector(3 downto 0); -- APAGAR DEPOIS

begin

    mem_proc: process(reset, clock) -- bloco de memoria
    begin
        if reset = '1' then
            state <= zero; --! inicio (reset assincrono)
        end if;

        if clock'event and clock = '1' then --! borda de subida

            if ((carrega AND (NOT gestosEmEspera)) = '1')  then -- carrega = 1 e jogadores prontos
                state <= next_state;
            end if;
        
            if (unsigned(bit_placarA) > (unsigned(unsigned(bit_placarB) + unsigned(bit_jogosRestantes)))) then -- placarA > placarB+jogosRestantes
                aGanhaMatch <= '1';
            else
                aGanhaMatch <= '0';
            end if;

            if (unsigned(bit_placarB) > (unsigned(unsigned(bit_placarA) + unsigned(bit_jogosRestantes)))) then
                bGanhaMatch <= '1';
            else
                bGanhaMatch <= '0';
            end if;

        end if;

    end process;

    gestosEmEspera <= '1' when ((gestoA = "00") or (gestoB = "00")) else
                      '0';

    next_state <= zero when state = vitoriaA or state = vitoriaB else
                  inicio   when state = zero and inicia = '1' else  -- COLOCAR DEPOIS and (NOT nJogosRegistrado) = '0' else
                  roundsEmExecucao  when state = inicio or ((state = roundsEmExecucao)) else
                  vitoriaA when state = roundsEmExecucao and aGanhaMatch = '1' else
                  vitoriaB when state = roundsEmExecucao and bGanhaMatch = '1';

    with state select 
        loadNJogos <= '1' when zero, -- To confuso ainda com qual estado coloco aq
                      '1' when inicio,
                      '0' when others;

    registradorNJogos: registrador port map(clock, reset, loadNJogos, nJogos, nJogosRegistrado); -- Armazena o valor de nJogos                                                                            

    rodada: jokempo port map(gestoA, gestoB, bit_zRodada); -- zRodada recebe o resultado da rodada

    aGanhou <= '1' when bit_zRodada = "10" else '0'; -- A ganha a rodada
    bGanhou <= '1' when bit_zRodada = "01" else '0'; -- B ganha a rodada

    contadorPlacarA: contador port map(carrega, reset, aGanhou, bit_placarA); --  placarA ++ when zRodada = "10";
    contadorPlacarB: contador port map(carrega, reset, bGanhou, bit_placarB); --  placarB++ when zRodada = "01";
                                      -- clock = carrega
    
    contadorJogosRestantes: decreaser port map(clock, reset, loadNJogos, nJogosRegistrado, carrega, bit_jogosRestantes); -- Decreaser acontece durante o carrega
                                            -- clock, reset, load      , addValue*,       , decrease, parallel_out
                                            -- * TALVEZ SEJA nJOGOSREGISTRADO

    placarA <= bit_placarA;
    placarB <= bit_placarB;
    jogosRestantes <= bit_jogosRestantes;
    zRodada <= bit_zRodada;

    with state select 
        zMatch <= "10" when vitoriaA,
                  "01" when vitoriaB,
                  "00" when others;

    
    with state select
        estadoAtual <= "0000" when zero,
                       "0001" when inicio,                  
                       "0010" when roundsEmExecucao,
                       "0011" when vitoriaA,
                       "0100" when vitoriaB;

end jkpn_arch ; -- jkpn_arch

library ieee;
use ieee.numeric_bit.all;

entity contador is
  port (
    clock, reset: in bit; -- Reset assincrono
    count:        in bit; -- Incrementa a contagem
    parallel_out: out bit_vector(3 downto 0) -- Conteudo do contador
  ) ;
end contador;

architecture contador_arch of contador is
    signal internal: unsigned(3 downto 0);

begin
    contador_process: process(clock, reset)
    begin
        if reset = '1' then 
            internal <= (others=>'0');
        end if;

        if clock'event and clock = '1' then
            if count = '1' then
                internal <= internal + 1;
            end if;
        end if;
    end process contador_process;
    parallel_out <= bit_vector(internal);
end contador_arch ; -- contador_arch

library ieee;
use ieee.numeric_bit.all;

entity registrador is
  port (
    clock, reset: in bit; -- Reset assincrono
    load:         in bit; -- Carrega o valor
    addValue:     in bit_vector(3 downto 0); -- Carrega o valor no registrador  
    parallel_out: out bit_vector(3 downto 0) -- Conteudo do registrador
  );
end registrador;

architecture registrador_arch of registrador is
    
    signal internal: unsigned(3 downto 0);

begin
    registrador_process: process(clock, reset)
    begin
        if reset = '1' then 
            internal <= (others=>'0');
        end if;

        if clock'event and clock = '1' then -- Durante o clock 
            if load = '1' then
                internal <= unsigned(addValue); -- Carrega o valor
            end if;
        end if;
    end process registrador_process;
    parallel_out <= bit_vector(internal); 

end registrador_arch ; -- registrador_arch

library ieee;
use ieee.numeric_bit.all;

entity decreaser is
  port (
    clock, reset: in bit; -- Reset assincrono
    load:         in bit; -- Carrega o valor
    addValue:     in bit_vector(3 downto 0); -- Carrega o valor no registrador
    decrease:        in bit; -- Decrementa a contagem
    parallel_out: out bit_vector(3 downto 0) -- Conteudo do contador
  );
end decreaser;

architecture decreaser_arch of decreaser is

signal internal: unsigned(3 downto 0);

begin
    registrador: process(clock, reset)
    begin
        if reset = '1' then 
            internal <= (others=>'0');
        end if;

        if clock'event and clock = '1' then -- Durante o clock 
            if load = '1' then
                internal <= unsigned(addValue); -- Carrega o valor
            
            elsif decrease = '1' then
                internal <= internal - 1;
            end if;
        end if;
    end process registrador;
    parallel_out <= bit_vector(internal); 


end decreaser_arch ; -- decreaser_arch

-- Abaixo, apenas copia das entity jokempo do
-- projeto 1, para instanciar.

-- T1A1:
entity jokempo is
    port (
      a: in bit_vector(1 downto 0); --! gesto do jogador A
      b: in bit_vector(1 downto 0); --! gesto do jogador B
      y: out bit_vector(1 downto 0) --! resultado do jogo
    );
  end jokempo;
  
  architecture jokempo_arch of jokempo is
  begin
      -- Para a resolução desta arquitetura, optei por reduzir as saídas
      -- em expressões boolenas. Para isto, considera-se as seguintes
      -- equivalências:
      
      -- A = a(0); B = a(1); C = b(0); D = b(1).
  
      -- y(1) = AB'C + ABD + BC'D + A'BCD'
      y(1) <= ((a(0) and not a(1)) and b(0)) or
              ((a(0) and a(1)) and b(1))    or
              ((a(1) and not b(0)) and b(1)) or
              ((not a(0) and a(1)) and (b(0) and not b(1))); -- Possivelmente estão invertidos as entradas (0 e 1)
      
      -- y(0) = ACD' + BCD + A'BD + AB'C'D
      y(0) <= ((a(0) and b(0)) and not b(1)) or
              ((a(1) and b(0)) and b(1))     or
              ((not a(0) and a(1)) and b(1)) or
              ((a(0) and not a(1)) and (not b(0) and b(1))); 
  
  end jokempo_arch;
  
