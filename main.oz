functor
import
   GUI at 'GUI.ozf'
   Input at 'Input.ozf'
   PlayerManager at 'PlayerManager.ozf'
   System
   OS


define


   GUI_port

   Color
   PlayerList
   PortList

   Thirdfun
   LauchgameTurn
   Playturn
   Random
   SimultaneousGame
   StimulateThinking
   CreatePlayer
in

    %return a random number between 0 and N
   fun {Random N}
      {OS.rand} mod N + 1
   end


   proc {CreatePlayer}
      local TempList Secondfun  Guifun IDtemp Positiontemp in

	 fun {Secondfun IDNum PlayerInput ColorInput}
	    if IDNum > Input.nbPlayer then nil
	    else
	       case PlayerInput#ColorInput
	       of (Hplayer|Tplayer)#(Hcolor|Tcolor) then {PlayerManager.playerGenerator Hplayer Hcolor IDNum}|{Secondfun (IDNum+1) Tplayer Tcolor }
	       end
	    end
	 end

	 fun {Thirdfun TempPortList}
	    {System.show bitroooo}
	    local Positiontemp IDtemp in
	       case TempPortList
	       of H|T then
		  {Send H initPosition(IDtemp Positiontemp)}
		  {System.show arturitopo}

		  {Wait Positiontemp}
		  {System.show Positiontemp}
		  {System.show IDtemp}
		  {Send GUI_port initPlayer(IDtemp Positiontemp)}


		  {System.show kobe}

		  player(port:H id:IDtemp)|{Thirdfun T}
	       [] H then nil
	       end
	    end
	 end


	 PortList={Secondfun 1 Input.players Input.colors}
	 PlayerList={Thirdfun PortList}
      end
   end


   %play turn by turn
   fun {Playturn Player}

      local PosMine PosMissile ExplosionMissile  ExplosionMine in

					%placed func here so can use State
	 proc {ExplosionMissile Target}
	    local MessageMissile Death ID LifeLeft Damage in
	       {Send  Target sayMissileExplode(Player.id PosMissile MessageMissile)}
         {System.show waitingMessageExplosion}
	       {Wait MessageMissile}
         {System.show postMessageExplosion}

	       case MessageMissile
	       of nil then skip
	       []sayDeath(ID) then {Send GUI_port removePlayer(ID)} {List.forAll PortList proc{$ A} {Send A sayDeath(ID)} end}
	       []sayDamageTaken(ID Damage ?LifeLeft) then {Wait LifeLeft } {Send GUI_port lifeUpdate(ID LifeLeft)}{List.forAll PortList proc{$ A} {Send A sayDamageTaken(ID Damage LifeLeft)} end}
	       else skip
	       end
	    end
	 end

	 proc {ExplosionMine Target}
	    local MessageMine Death ID LifeLeft Damage in
	       {Send  Target sayMineExplode(Player.id PosMine MessageMine)}
	       {Wait MessageMine}
	       case MessageMine
	       of nil then skip
	       []sayDeath(ID) then {Send GUI_port removePlayer(ID)} {List.forAll PortList proc{$ A} {Send A sayDeath(ID)} end}
	       []sayDamageTaken(ID Damage ?LifeLeft) then {Send GUI_port lifeUpdate(ID LifeLeft)}{List.forAll PortList proc{$ A} {Send A sayDamageTaken(ID Damage LifeLeft)} end}
	       else skip
	       end
	    end
	 end



	 local DirTemp PosTemp ItemTemp FireTemp MineTemp  MessageDeath IdTarget PosTarget IdTargetSon PosTargetSon MessageMine Death in
							%Player choose to move
	    {Send Player.port move(Player.id PosTemp DirTemp)}
	    {Wait PosTemp}
	    {Wait DirTemp}
	    {Send GUI_port movePlayer(Player.id PosTemp)}


	    if PosTemp \= surface then {List.forAll PortList proc {$ PortA} {Send PortA sayMove(Player.id DirTemp)}  end}


	       %allow player to charge an Item
	       {Send Player.port chargeItem(Player.id ItemTemp)}
	       {Wait ItemTemp}
	       if ItemTemp \= null then	{List.forAll PortList proc {$ A} {Send A sayCharge(Player.id ItemTemp)} end} end

									%allow player to fire Item
	       {Send Player.port fireItem(Player.id FireTemp)}
	       {Wait FireTemp}
	       case FireTemp
	       of missile(pt(x:_ y:_)) then  PosMissile=FireTemp.1 {List.forAll PortList ExplosionMissile}
	       [] mine(pt(x:_ y:_))    then  PosMine=FireTemp.1    {Send GUI_port putMine(Player.id FireTemp.1)}
	       [] drone(_ _ )          then  {List.forAll PortList proc {$ PortA} local IdTarget PosTarget in {Send PortA sayPassingDrone(FireTemp IdTarget PosTarget)} {Send  Player.port sayAnswerDrone(FireTemp IdTarget PosTarget)} end end}
	       [] sonar 	       then  {List.forAll PortList proc {$ PortA} local IdTargetSon PosTargetSon in {Send PortA sayPassingSonar(IdTargetSon PosTargetSon)} {Send  Player.port sayAnswerSonar(IdTargetSon PosTargetSon)} end end}
	       else skip
	       end

	       %check if player died from a missile
	       {Send Player.port isDead(Death)}
	       {Wait Death}
	       if (Death \= true) then

		   %allow player to detonate mine
		  {Send Player.port fireMine(Player.id MineTemp)}
		  {Wait MineTemp}
		  if MineTemp \= null then
		     {List.forAll PortList ExplosionMine}
		     {Send GUI_port removeMine(Player.id MineTemp)}
		  end
	       end
	    else
	       {List.forAll PortList proc {$ A} {Send A  saySurface(Player.id)} end}
	       {Send Player.port dive}
	       {Send GUI_port surface(Player.id)}

	    end

	    {Send Player.port isDead(MessageDeath)}
	    {Wait MessageDeath}
	    MessageDeath
	 end
      end
   end

   proc {StimulateThinking}
      %{Delay ({OS.rand} mod (Input.thinkMax-Input.thinkMin+1)) + Input.thinkMin}
      {Delay {Random 100}}

   end


   proc {SimultaneousGame Player}
      local OneTurn DirTemp PosTemp ItemTemp FireTemp MineTemp ExplosionMine MessageDeath IdTarget PosTarget MessageMine PosMissile PosMine ExplosionMissile Death in

	 proc {OneTurn PlaceHolder}
            %Take a port in argument and broadcast his response to an missile explosion
	    proc {ExplosionMissile Target} %Attention pas de diff mine et missile
	       local MessageMissile Death in
		  {Send  Target sayMissileExplode(Player.id PosMissile MessageMissile)}
		  {Wait MessageMissile}
		  case MessageMissile
		  of nil then skip
		  []sayDeath(ID) then {Send GUI_port removePlayer(ID)} {List.forAll PortList proc{$ A} {Send A sayDeath(ID)} end}
		  []sayDamageTaken(ID Damage ?LifeLeft) then {Wait LifeLeft } {Send GUI_port lifeUpdate(ID LifeLeft)}{List.forAll PortList proc{$ A} {Send A sayDamageTaken(ID Damage LifeLeft)} end}
		  else skip
		  end
	       end
	    end
            %Take a port in argument and broadcast his response to an mine explosion
	    proc {ExplosionMine Target}
	       local MessageMine Death in
		  {Send  Target sayMineExplode(Player.id PosMine MessageMine)}
		  {Wait MessageMine}
		  case MessageMine
		  of nil then skip
		  []sayDeath(ID) then {Send GUI_port removePlayer(ID)} {List.forAll PortList proc{$ A} {Send A sayDeath(ID)} end}
		  []sayDamageTaken(ID Damage ?LifeLeft) then {Wait LifeLeft } {Send GUI_port lifeUpdate(ID LifeLeft)}{List.forAll PortList proc{$ A} {Send A sayDamageTaken(ID Damage LifeLeft)} end}
		  else skip
		  end
	       end
	    end



	    {Send Player.port move(Player.id PosTemp DirTemp)}
	    {Wait DirTemp}
	    {Send GUI_port movePlayer(Player.id PosTemp)}

	    {List.forAll PortList proc {$ A} {Send A sayMove(Player.id DirTemp)} end}
	    if DirTemp \= surface then
	       {StimulateThinking}
	       %allow player to charge an item
	       {Send Player.port chargeItem(Player.id ItemTemp)}
	       {Wait ItemTemp}

	       if ItemTemp \= null then {List.forAll PortList proc {$ A}  {Send A sayCharge(Player.id ItemTemp)} end} end

	        %allow player to fire Item
	       {Send Player.port fireItem(Player.id FireTemp)}
	       {Wait FireTemp}
	       case FireTemp
	       of missile(pt(x:_ y:_)) then  PosMissile=FireTemp.1 {List.forAll PortList ExplosionMissile}
	       [] mine(pt(x:_ y:_))    then  PosMine=FireTemp.1    {Send GUI_port putMine(Player.id FireTemp.1)}
	       []	drone(_ _ )    then  {List.forAll PortList proc {$ PortA} local IdTarget PosTarget in {Send PortA sayPassingDrone(FireTemp IdTarget PosTarget)} {Send  Player.port sayAnswerDrone(FireTemp IdTarget PosTarget)} end end}
	       [] sonar 	       then  {List.forAll PortList proc {$ PortA} local IdTargetSon PosTargetSon in {Send PortA sayPassingSonar(IdTargetSon PosTargetSon)} {Send  Player.port sayAnswerSonar(IdTargetSon PosTargetSon)} end end}
	       else skip
	       end


	       {Send Player.port isDead(Death)}
	       {Wait Death}
	       if (Death \= true) then
														%allow player to detonate mine
		  {Send Player.port fireMine(Player.id MineTemp)}
		  {Wait MineTemp}
		  if MineTemp \= null then
		     {List.forAll PortList ExplosionMine}
		     {Send GUI_port removeMine(Player.id MineTemp)}
		  end
	       end
	    else
	       {Send GUI_port surface(Player.id)}
	       {Delay Input.turnSurface}
	       {Send Player.port dive}
	    end
	 end% fin OneTurn


	 local MessageDeath in
	    {StimulateThinking}
	    {Send Player.port isDead(MessageDeath)}
	    {Wait MessageDeath}
	    if MessageDeath == false then
	       {OneTurn 0}
	       {SimultaneousGame Player}
      else
          {System.show 'Player dead'}
          {System.show Player.id}

	    end
	 end
      end%fin local
   end




   %Launch game in turn by turn
   proc {LauchgameTurn  AliveList PlayerLeft}
%PlayerLeft < 2
      if PlayerLeft<1 then {System.show wiiinnneeerr}  {System.show AliveList} {System.show PlayerLeft} %{List.forAll AliveList proc{$ A} local Mes in{Send A.port isDead(Mes)}{Wait Mes}{System.show Mes} end end }

      else
	 local Message in
	    case AliveList
	    of nil then {System.show 'no player , something went wrong'}
	    [] H|T then
	       if H==nil then {LauchgameTurn {List.append T H|nil } PlayerLeft}
	       else
		  {Send H.port isDead(Message)} {Wait Message}
		  if Message==false then if {Playturn H }==false then {LauchgameTurn {List.append T H|nil } PlayerLeft}
					 else {LauchgameTurn T PlayerLeft-1}
					 end
		  else {Send GUI_port removePlayer(H.id)} {LauchgameTurn T PlayerLeft-1 }
		  end

	       end
	    end
	 end
      end
   end






	% initialise le GUI port ainsi que les players et leurs positions
   GUI_port = {GUI.portWindow}
   {Send GUI_port buildWindow}
   {CreatePlayer}




   %Send the intial dive signal
   {List.forAll PortList proc {$ A} {Send A dive} end}

   if Input.isTurnByTurn then
      {LauchgameTurn PlayerList Input.nbPlayer }

   else
      {List.forAll PlayerList (proc {$ Player} thread {SimultaneousGame Player} end end)}
      {System.show endgame}
   end
end

%deal with endgame simul



%Couleur et initiation des joueur pas clair
%initier player corectement
%retirer joueur mort de l'UI dans tout les cas % dpne
%broadcast % merci a moi pour ce comment % merci mec
%quitter le programme % pass besoin selon ben
%listMine				% A implémenter % non?
