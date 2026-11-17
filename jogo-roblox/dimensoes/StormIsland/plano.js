/* Ilha das Tempestades — plano da ilha (fonte única de verdade do layout)
   Coordenadas em studs. X = leste, Z = sul (chegada), Y = altura. Ilha ≈ 560 × 440 studs.
   Regras de escala: avatar ≈ 5 studs; caminhos com 12 a 16 studs de largura (mín. 8 nas rotas secretas);
   portas ≥ 8 studs; inclinação máxima dos caminhos ≈ 18° (rampa 0,33). */
(function(){const MM=window.MM;
MM.islands.StormIsland={
  id:'StormIsland',nome:'Ilha das Tempestades',
  paleta:{pedra:'#4a5168',pedraClara:'#6d7590',pedraEscura:'#2b3042',alvenaria:'#6c6876',metal:'#a7b0c4',metalEscuro:'#3d4458',cobre:'#b0703c',patina:'#3f8f86',
    madeira:'#4a3b3a',telhado:'#36405a',corda:'#6a5d52',vidro:'#1c2440',janela:'#ffb35c',cristal:'#7fe4ff',energia:'#43d9ff',lanterna:'#ffc27a',
    folhagem:'#3d3652',casca:'#2a2734',veio:'#5fd3ff',tecido:'#5a3d6b',musgo:'#3b5a50',musgo2:'#4d6b5c',rocha:'#57565f',rochaAlta:'#7d7c86',trilha:'#aaa699',penhasco:'#2a2d3e',
    ceuTopo:'#070a19',ceuMeio:'#141a3a',ceuHorizonte:'#2a2f5c',nevoa:'#1a2140',violeta:'#7a4dff',azul:'#2f7bff',ciano:'#43d9ff',prata:'#b8c2d6'},
  /* pontos de interesse: centro, raio e altura do platô (h = altura do chão em studs) */
  poi:{
    chegada:{x:0,z:186,h:9,nome:'Chegada (doca de pedra)'},
    vila:{x:-34,z:92,r:58,h:16,nome:'Vila dos Para-raios'},
    torre:{x:32,z:-26,r:30,h:36,nome:'Torre Meteorológica'},
    floresta:{x:-158,z:18,r:82,nome:'Floresta Eletrificada'},
    caverna:{x:-150,z:-102,nome:'Caverna do Trovão',boca:{x:-150,z:-104},dir:[0,1]},
    penhasco:{x:222,z:44,h:26,nome:'Penhasco das Nuvens'},
    observatorio:{x:150,z:-128,r:28,h:66,nome:'Observatório Abandonado'},
    santuario:{x:-228,z:150,r:20,h:10,nome:'Santuário da Tempestade (secreto)'}},
  /* caminhos: [x,z] em sequência; w = largura total em studs; tipo principal/alternativo/secreto */
  caminhos:[
    {id:'P1',nome:'Caminho principal: chegada → vila → torre',w:16,tipo:'principal',pts:[[0,186],[-4,150],[-20,118],[-34,92],[-18,58],[4,30],[18,26],[32,26]]},/* V2.3.1: termina no pé da escadaria da torre (antes entrava na base da torre em 30,−10) */
    {id:'P2',nome:'Trilha da floresta até a Caverna do Trovão',w:12,tipo:'principal',pts:[[-62,88],[-104,66],[-140,42],[-168,8],[-172,-36],[-158,-74],[-150,-98]]},
    {id:'P3',nome:'Estrada do penhasco (atravessa a ponte suspensa)',w:12,tipo:'principal',pts:[[-6,100],[40,104],[86,96],[140,82],[186,62],[214,46]]},
    {id:'P4',nome:'Serpentina do observatório',w:10,tipo:'principal',pts:[[46,26],[58,8],[70,-12],[86,-44],/* V2.3.1: sai do pé da escadaria, contornando a colina (antes começava dentro da base da torre) */[112,-62],[104,-84],[126,-98],[148,-106]]/* V2.3.2: termina diante da porta do observatório (antes em 142,−116, dentro da parede) */},
    {id:'P5',nome:'Passagem secreta para o santuário',w:8,tipo:'secreto',pts:[[-176,58],[-198,92],[-214,122],[-226,146]]},
    {id:'P6',nome:'Rota alternativa pela crista leste',w:10,tipo:'alternativo',pts:[[186,62],[192,20],[186,-26],[176,-70],[160,-108]]}],
  /* fenda que corta a ilha até as nuvens: a estrada do penhasco cruza por uma ponte suspensa */
  /* torres da linha de transmissão (props.js) — a vila usa para não pôr porta de casa colada numa torre */
  /* rochas que escondem a passagem secreta [x,z,tamanho] — props.js desenha; floresta.js evita */
  rochasSecretas:[[-193,60,12],[-166,68,10],[-206,76,14],[-173.5,50,9]],
  linhaTransmissao:[[72,30],[20,52],[-2,74],[24,112],[66,108]],
  fenda:{a:[106,154],b:[120,22],largura:13},
  pontes:[{id:'STORM.BRIDGE.01',nome:'Ponte Suspensa da Fenda',a:[96,94],b:[132,84],w:8}],
  minas:[
    {id:'STORM.MINE.01',x:-118,z:52,nome:'Afloramento da floresta'},
    {id:'STORM.MINE.02',x:-150,z:-150,nome:'Câmara de cristais (dentro da caverna)',interno:true},
    {id:'STORM.MINE.03',x:96,z:-66,nome:'Veio da encosta da torre'},
    {id:'STORM.MINE.04',x:196,z:84,nome:'Borda do penhasco'}],
  /* marcadores técnicos: NÃO são mecânicas implementadas, só a posição e o propósito previstos */
  marcadores:[
    ['STORM.SPAWN.01','Spawn','Chegada dos jogadores',0,186],
    ['STORM.PORTAL.01','Portal','Portal de volta ao hub (arco da doca)',0,198],
    ['STORM.NPC.01','NPC','Guardião da Torre (porta da torre)',32,4],
    ['STORM.NPC.02','NPC','Ferreira dos Para-raios (oficina da vila)',-52,82],
    ['STORM.NPC.03','NPC','Meteorologista eremita (observatório)',140,-112],
    ['STORM.MINE.01','Mineração','Afloramento da floresta',-118,52],
    ['STORM.MINE.02','Mineração','Câmara de cristais da caverna',-150,-150],
    ['STORM.MINE.03','Mineração','Veio da encosta da torre',96,-66],
    ['STORM.MINE.04','Mineração','Borda do penhasco',196,84],
    ['STORM.COLLECT.01','Coleta','Flores-faísca da floresta',-176,30],
    ['STORM.COLLECT.02','Coleta','Fragmentos de nuvem no penhasco',226,30],
    ['STORM.COLLECT.03','Coleta','Peças de máquina no observatório',162,-138],
    ['STORM.PUZZLE.TOWER','Puzzle','Alinhar os para-raios da torre',32,-26],
    ['STORM.PUZZLE.OBS','Puzzle','Apontar o telescópio quebrado',150,-128],
    ['STORM.SECRET.01','Área secreta','Santuário da Tempestade',-228,150],
    ['STORM.DISCOVERY.01','Descoberta','Inscrição das Sete Estrelas no santuário',-228,156],
    ['STORM.EQUIP.01','Equipamento secreto','Bobina antiga no fundo da caverna',-156,-162],
    ['STORM.WEATHER.01','Evento climático','Zona de tempestade elétrica (cume norte)',-40,-150],
    ['STORM.HIDDEN.01','Passagem oculta','Fresta entre as rochas para a trilha secreta',-178,62]]
};})();
