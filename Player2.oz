functor
import
   Input at 'Input.ozf'
   Player at 'Player2.ozf'
   OS
   System
export
   portPlayer:StartPlayer
define
   StartPlayer
   TreatStream
   Move
   ChargeItem
   FireItem
   FireMine
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayPassingSonar

   %fcts ajoutées
   IsIsland
   Histo
   IsValidPath
   Random
   RandomPosition
   FindInList
   RemoveFromList
   GetNewPos
   Where
   ValidItem
in

   fun{IsIsland L X Y} %testé et approuvé
      local IsIsland2 in
	 fun{IsIsland2 M A}
	    if A==1 then M.1
	    else {IsIsland2 M.2 A-1}
	    end
	 end
	 {IsIsland2 {IsIsland2 L X} Y}
      end
   end

   fun{Histo L E} %testé et approuvé
      {System.show [onesthisto L E]}
      case L of nil then true
      [] H|T then
	 if H==E then false
	 else {Histo T E}
	 end
      end
   end

   fun{IsValidPath L E} %testé et approuvé
      local X Y in
	 pt(x:X y:Y)=E
	 (X >= 1 andthen X =< Input.nRow andthen Y >= 1 andthen Y =< Input.nColumn) andthen {IsIsland Input.map X Y} == 0 andthen {Histo L E}
      end
   end

   fun {Random N}
      {OS.rand} mod N + 1
   end

   %Je suppose qu'il n'existe aucune colonne avec que des 1
   fun{RandomPosition M}
      local X Y in
	 X={Random Input.nRow}
	 Y={Random Input.nColumn}
	 if {IsIsland M X Y}==0 then pt(x:X y:Y)
	 else {RandomPosition M}
	 end
      end
   end

   fun {FindInList L N}
      if N==1 then L.1
      else {FindInList L.2 N-1}
      end
   end

   fun{RemoveFromList L A}
      case L of nil then nil
      [] H|T then
	 if H==A then {RemoveFromList T A}
	 else H|{RemoveFromList T A}
	 end
      end
   end

   %deal with false path also perfect place for intelligence while move is logisstic
   fun {GetNewPos State L}
      if L==nil then nil
      else
	 local CandPos CandDir PosDir in
	    CandDir={FindInList L {Random {List.length L}}}
             % pick at random a path
	    case CandDir of east then CandPos=pt(x:State.pos.x y:State.pos.y+1)
	    [] south then CandPos=pt(x:State.pos.x+1 y:State.pos.y)
	    [] west then CandPos=pt(x:State.pos.x y:State.pos.y-1)
	    [] north then CandPos=pt(x:State.pos.x-1 y:State.pos.y)
	    end

            %check if pos is valid
	    if ({IsValidPath State.path CandPos}==true) then       %isvalid surface bug?
	       PosDir=CandPos|CandDir
	    else
	       {GetNewPos State {RemoveFromList L CandDir}}
	    end
	 end
      end
   end

   fun{SayMissileExplode ID Position ?Message State}%simon

      if Position.y==State.pos.y andthen Position.x==State.pos.x then
	 if (State.life < 3 )then
	    Message=sayDeath(State.id)
	    {Record.adjoin State player(life:State.life-State.life)}

	 else
	    Message=sayDamageTaken(State.id 2 State.life-2)
	    {Record.adjoin State player(life:State.life-2)}
	 end
      else
	 if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
	    if State.life < 2 then
	       Message=sayDeath(State.id)
	       {Record.adjoin State player(life:State.life-State.life)}

	    else
	       Message=sayDamageTaken(State.id 1 State.life-1)
	       {Record.adjoin State player(life:State.life-1)}

	    end
	 else
	    Message=sayDamageTaken(State.id 0 State.life)
	    State
	 end
      end
   end

   fun{SayMineExplode ID Position ?Message State}%simon
      if Position.y==State.pos.y andthen Position.x==State.pos.x then
	 if (State.life < 3 )then
	    {Record.adjoin State player(life:State.life-State.life)}
	    Message=sayDeath(State.id)
	 else
	    Message=sayDamageTaken(State.id 2 State.life-2)
	    {Record.adjoin State player(life:State.life-2)}
	 end
      else
	 if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
	    if State.life < 2 then
	       {Record.adjoin State player(life:State.life-State.life)}
	       Message=sayDeath(State.id)
	    else
	       Message=sayDamageTaken(State.id 1 State.life-1)
	       {Record.adjoin State player(life:State.life-1)}
	    end
	 else
	    Message=sayDamageTaken(State.id 0 State.life)
	    State
	 end

      end
   end

   fun{SayPassingDrone Drone State}
      case Drone of drone(row X) then
	 if State.pos.x==X then true
	 else false
	 end
      [] drone(column Y) then
	 if State.pos.y==Y then true
	 else false
	 end
      else false
      end
   end

   fun{SayPassingSonar State}
      local R in
	 R={Random 2}
	 if R==1 then
	    pt(x:State.pos.x y:{Random Input.nColumn})
	 else
	    pt(x:{Random Input.nRow} y:State.pos.y)
	 end
      end
   end

   fun{Move ?Position ?Direction State}
      {System.show [path State.path]}
      if(State.nbMove==1) then
	 Direction=surface
	 Position=State.pos
	 {Record.adjoin State player(nbMove:6 immersed:false path:Position|nil)}
      else
	 local ListPosDir in
	    ListPosDir =  {GetNewPos State [east north west south]}
	    if ListPosDir==nil then
	       Direction=surface
	       Position=State.pos
	       {Record.adjoin State player(nbMove:6 immersed:false path:Position|nil)}
	    else
	       Position=ListPosDir.1
	       Direction=ListPosDir.2
	       {Record.adjoin State player(pos:Position nbMove:State.nbMove-1 path:Position|State.path)}
	    end
	 end
      end
   end


   fun{ChargeItem ?KindItem State}
      local PosItem ChargeItem2 in
	 fun{ChargeItem2 TempItem}
	    case TempItem of mine then
	       if State.loadMine+1==Input.mine then
		  KindItem=mine
		  {Record.adjoin State player(loadMine:0 numberMine:State.numberMine+1)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadMine:State.loadMine+1)}
	       end
	    [] missile then
	       if State.loadMissile+1==Input.missile then
		  KindItem=missile
		  {Record.adjoin State player(loadMissile:0 numberMissile:State.numberMissile+1)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadMissile:State.loadMissile+1)}
	       end
	    [] drone then
	       if State.loadDrone+1==Input.drone then
		  KindItem=drone
		  {Record.adjoin State player(loadDrone:0 numberDrone:State.numberDrone+1 item:2)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadDrone:State.loadDrone+1)}
	       end
	    [] sonar then
	       if State.loadSonar+1==Input.sonar then
		  KindItem=sonar
		  {Record.adjoin State player(loadSonar:0 numberSonar:State.numberSonar+1 item:1)}
	       else
		  KindItem=null
		  {Record.adjoin State player(loadSonar:State.loadSonar+1)}
	       end
	    end
	 end
	 {ChargeItem2 missile}
      end
   end

   %choisis quelle item a launch , coder IA ici et fireItem fait la logistique
   fun {ValidItem ListFire State}
      if ListFire==nil then nil
      else
	 case ListFire.1 of mine then
	    if State.numberMine>0 then
	       mine|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end

	 [] missile then
	    if State.numberMissile>0 then
	       missile|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end

	 [] drone then
	    if State.numberDrone>0 then
	       drone|{ValidItem ListFire.2 State}
	    else
	       {ValidItem ListFire.2 State}
	    end

	 [] sonar then
	    if State.numberSonar>0 then
	       sonar|{ValidItem ListFire.2 State}

	    else
	       {ValidItem ListFire.2 State}
	    end
	 [] rien then rien|{ValidItem ListFire.2 State}

	 end
      end
   end

   fun{FireItem ?KindFire State} % Listfire étrange? version smart buggé donc remplacé par tout con , peut etre trouvée au commit updateplayer du 20/4
      local Fire in
	 Fire={ValidItem [missile sonar drone mine rien]  State}.1
	 case Fire of mine then
	    KindFire=mine(State.pos)
	    {Record.adjoin State player(listMine:KindFire|State.listMine numberMine:State.numberMine-1)}

	 [] missile then
	    KindFire=missile({RandomPosition Input.map})
	    {Record.adjoin State player(numberMissile:State.numberMissile-1)}

	 [] drone then
	    KindFire=drone(row:{Random Input.nRow}) % nrow bugged? remplaced by 8 for the time being
	    {Record.adjoin State player(numberDrone:State.numberDrone-1)}

	 [] sonar then
	    KindFire=sonar
	    {Record.adjoin State player(numberSonar:State.numberSonar-1)}
	 else
	    KindFire=null
	    State
	 end
      end

   end

   fun{FireMine ?Mine State}
      if State.listMine==nil then
	 Mine=null
	 State
      else
	 Mine=State.listMine.1.1 %first object first argument (which is position)
	 {Record.adjoin State player(listMine:{RemoveFromList State.listMine State.listMine.1})}
      end
   end


   fun{StartPlayer Color ID}
      Stream
      Port
      PlayerState
   in
      {System.show bite}
      %immersed pour savoir si il est en surface ou pas
      PlayerState = player(id:id(id:ID color:Color name:fishy) path:nil nbMove:6 pos:nil immersed:false life:Input.maxDamage listMine:nil loadMine:0 numberMine:0 loadMissile:0 numberMissile:0 loadDrone:0 numberDrone:0 loadSonar:0 numberSonar:0)
      {NewPort Stream Port}
      thread
	 {System.show start_playfdp}
	 {TreatStream Stream PlayerState}
      end
      Port
   end

   proc {TreatStream Stream State}
      {System.show state}
      {System.show [historik State.path]}

      case Stream of nil then skip
      [] initPosition(?ID ?Position)|T then
	 {System.show initPosition1}
	 ID=State.id
	 Position={RandomPosition Input.map}
	 local Newstate in
	    Newstate={Record.adjoin State player(pos:Position path:Position|nil)}
	    {System.show initPosition2}
	    {TreatStream T Newstate}
	 end

      [] move(ID ?Position ?Direction)|T then
	 {System.show onestdansmove}
	 ID=State.id
	 local Newstate in
	    Newstate={Move ?Position ?Direction State}
      {System.show [direction Direction]}
	    {System.show mooove}
	    {TreatStream T Newstate}
	 end

      [] dive|T then
	 {System.show dive}
	 local Newstate in
	    Newstate={Record.adjoin State player(immersed:true)}
	    {System.show plongeeSousMarine}
	    {TreatStream T Newstate}
	 end

      [] chargeItem(?ID ?KindItem)|T then
	 {System.show chargeItem}
	 ID=State.id
	 local Newstate in
	    Newstate={ChargeItem ?KindItem State}
	    {System.show chargeItem2}
	    {TreatStream T Newstate}
	 end

      [] fireItem(?ID ?KindFire)|T then
	 {System.show fireItem1}
	 ID=State.id
	 local Newstate in
	    Newstate={FireItem ?KindFire  State}
	    {System.show fire_done}
	    {TreatStream T Newstate}
	 end

      [] fireMine(?ID ?Mine)|T then
	 {System.show fireMine}
	 ID=State.id
	 local Newstate in
	    Newstate={FireMine ?Mine State}
	    {System.show fireMine_done}
	    {TreatStream T Newstate}
	 end

      [] isDead(?Answer)|T then
	 {System.show isDead}
	 if State.life==0 then Answer=true
	 else Answer=false
	 end
	 {System.show isDead2}
	 {TreatStream T State}

      [] sayMove(ID Direction)|T then
	 {System.show sayMove}
	 {TreatStream T State}
	 {System.show saymooove_done}

      [] saySurface(ID)|T then
	 {System.show saySurface}
	 {TreatStream T State}

      [] sayCharge(ID KindItem)|T then
	 {System.show sayCharge_done}
	 {TreatStream T State}

      [] sayMinePlaced(ID)|T then
	 {System.show sayMinePlaced}
	 {TreatStream T State}

      [] sayMissileExplode(ID Position ?Message)|T then %simon
	 {System.show sayMissileExplode1}
	 local Newstate in
	    Newstate={SayMissileExplode ID.id Position Message State}
	    {System.show Message}
	    {System.show missileecplosion}
	    {TreatStream T Newstate}
	 end

      [] sayMineExplode(ID Position ?Message)|T then %simon
	 {System.show sayMineExplode1}
	 local Newstate in
	    Newstate={SayMineExplode ID.id Position Message State}
	    {System.show sayMineExplode2}
	    {TreatStream T Newstate}
	 end

      [] sayAnswerDrone(Drone ID Answer)|T then
	 {TreatStream T State}
      [] sayPassingDrone(Drone ?ID ?Answer)|T then
	 {System.show sayPassingDrone1}
	 ID=State.id
	 Answer={SayPassingDrone Drone State}
	 {System.show sayPassingDrone2}
	 {TreatStream T State}

      [] sayAnswerSonar(ID Answer)|T then
	 {System.show sayAnswerSonar2}
	 {TreatStream T State}
      [] sayPassingSonar(?ID ?Answer)|T then
	 {System.show sayPassingSonar1}
	 ID=State.id
	 Answer={SayPassingSonar State}
	 {System.show sayPassingSonar2}
	 {TreatStream T State}

      [] sayDeath(ID)|T then
	 {TreatStream T State}

      [] sayDamageTaken(ID Damage LifeLeft)|T then %dégats des ennemis seulement
	 {TreatStream T State}

      else
	 {System.show noMatchingInTreatStream}
	 {System.show Stream}

      end
   end
end
