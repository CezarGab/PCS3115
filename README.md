## Introdução
Olá! Este repositório armazena os projetos desenvolvidos para entrega durante a realização da disciplina **Sistemas Digitais I**, no ano de 2021, no curso de Engenharia Elétrica da *Escola Politécnica da USP*. A matéria foi coordenada pelo Prof. Glauber De Bona e ministrada por ele e pelos professores Marco Tulio e Marcos Simplício. 
O objetivo em tornar estes arquivos públicos se baseia em...

  - Permitir que futuros alunos desta disciplina possam consultar os códigos desenvolvidos aqui, podendo utilizar como fonte de pesquisa/estudos;  
  - Disponibilizar estes arquivos para qualquer interessado no estudo de VHDL;
  - Servir como fonte de estudo pessoal meu, para consultas futuras sobre o conteúdo abordado.



### Qual o conteúdo abordado?

Os Projetos buscam utilizar VHDL -  com restrições para o uso de poucas ou nenhuma biblioteca - para aplicar noções de Circuitos Digitais, desde a síntese de expressões booleanas até projetos de máquinas de estado.
Flip-flops, contadores, registradores, código de Hamming (detecção e correção de erro) e uso de components também integram os conhecimentos utilizados nestes arquivos e enunciados. 


## Notas obtidas

*OBS: o sistema de avaliação para os exercícios era automático, através do Sharif Judge interno do departamento. Não houve relatório do sistema para os erros que a correção encontrou.*

| Avaliação | Nota obtida |
|--------|---------------|
| Projeto 1   | 10       |
| Projeto 2   | 10       |
| Projeto 3   | 10       |
| Projeto 4   | 0,7      |
| **Média dos Projetos**    | 7,68 |



## Screenshots
--

## Rodando os códigos

Todos os arquivos foram desenvolvidos localmente pelo Visual Studio Code e verificados utilizando GHDL e GTKWave, conforme recomendado pelos professores. Porém, recomendo rodar os códigos usando o repositório pelo [Gitpod](https://gitpod.io/#https://github.com/CezarGab/PCS3115/). 
Utilizando o Gitpod para visualizar o Projeto 1, por exemplo, primeiro instalamos o GHDL através do Terminal.

```
sudo apt install ghdl
```
Navegamos até o diretório que queremos. Por exemplo:
```
cd "Projeto 1 - Jokempo"
```

E rodamos o arquivo pelo GHDL, utilizando a respectiva testbench do arquivo: 
```
ghdl -i [Arquivo a ser testado].vhd [Arquivo do testbench].vhd  && ghdl -m  [Nome da entidade do Testbench] && ghdl -r  [Nome da entidade do Testbench]
```

Por exemplo:
```
ghdl -i t4a1.vhd testbench_t4a1.vhd  && ghdl -m  testbench && ghdl -r  testbench
```

> **IMPORTANTE**: Os testbenchs finais que utilizei durante o desenvolvimento não são de minha autoria e, portanto, não estão públicos neste repositório. Caso queira ajuda para visualizar as saídas que obtive, fique a vontade para [entrar em contato](https://www.linkedin.com/in/cezar-gabriel/). 

É possível também gerar as saídas de ondas em .vcd:
```
ghdl -e [Nome da entidade do Testbench] && ghdl -r [Nome da entidade do Testbench] --vcd=[Nome do arquivo de saída].vcd
```
Por exemplo:
```
ghdl -e testbench && ghdl -r testbench --vcd=simul.vcd
```

Para visualizar as formas  de onda no arquivo gerado através do Gitpod, vá nas Extensões (Ctrl+Shift+X), procure por *"impulse"* e instale-o. Pronto, basta abrir o ".vcd" e vislumbrar como os zeros e uns estão se comportando.

> No _VS Code_ há também o *WaveTrace* que, apesar de possuir limitações na versão gratuita, tem uma interface bem bonita.


### Desenvolvimento

Por certa falta de tempo e desinteresse meu, o último projeto não foi escrito corretamente (e, consequentemente, recebeu uma nota bem simbólica). Além disso, os outros arquivos ficaram bastante extensos e certamente são passíveis de otimização. Assim, caso encontre os erros e/ou veja oportunidade de melhorias, sinta-se convidado a contribuir com a edição, pois ela certamente será bem-vinda.

## Termos de uso

Todos os direitos sob os enunciados e requisições da disciplina estão reservados para os professores responsáveis e são reproduzidos e compartilhados aqui para, e somente para, consulta. Já os códigos aqui presentes foram desenvolvidos pelos contribuidores e são de livre utilização.
