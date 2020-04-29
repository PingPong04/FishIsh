functor
import
   Input at 'Input.ozf'
   Browser(browse:Browse)
   Player at 'Player.ozf'
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
   SayMove
   SaySurface
   SayCharge
   SayMinePlaced
   SayMissileExplode
   SayMineExplode
   SayPassingDrone
   SayAnswerDrone
   SayPassingSonar
   SayDamageTaken

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
   TournerMap
   IsValidPathEnemy
   ValidItem
   RemoveDrone
   RemoveSonar
   Lista
   MaxIteration
   ListOfPoint
   Drone
   CreatePlayer
   InverseList
   FindValidTarget
   Bite%a enlever
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

   %Cette fonction permet de créer une liste avec les positions potentielles de l'ennemi IDEnemy
   %fct à faire tourner au début, génère tous les points où il y a pas d'ile sur la map et la retourne sous forme de liste
   fun{TournerMap K} % testée et approuvée
      local TournerMap2 in
	 fun {TournerMap2 X Y Acc}
	    if Y>Input.nColumn then
	       Acc
	    elseif X>Input.nRow then {TournerMap2 1 Y+1 Acc}
	    else
	       if {IsIsland Input.map X Y}==0 then
		  {TournerMap2 X+1 Y pt(x:X y:Y)|Acc}
	       else
		  {TournerMap2 X+1 Y Acc}
	       end
	    end
	 end
	 {TournerMap2 K K nil}
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

   fun{RemoveDrone Li Xi N} %testée et approuvée
      local Point X Y in
	 if N==1 then %True et X
	    case Li of nil then nil
	    []H|T then
	       X=H.x
	       Y=H.y
	       Point=pt(x:X y:Y)
	       if X==Xi then
		  Point|{RemoveDrone T Xi N}
	       else
		  {RemoveDrone T Xi N}
	       end
	    end
	 elseif N==2 then %False et X
	    case Li of nil then nil
	    []H|T then
	       X=H.x
	       Y=H.y
	       Point=pt(x:X y:Y)
	       if X==Xi then
		  {RemoveDrone T Xi N}
	       else
		  Point|{RemoveDrone T Xi N}
	       end
	    end
	 elseif N==3 then %True et Y
	    case Li of nil then nil
	    []H|T then
	       X=H.x
	       Y=H.y
	       Point=pt(x:X y:Y)
	       if Y==Xi then
		  Point|{RemoveDrone T Xi N}
	       else
		  {RemoveDrone T Xi N}
	       end
	    end
	 else %False et Y
	    case Li of nil then nil
	    []H|T then
	       X=H.x
	       Y=H.y
	       Point=pt(x:X y:Y)
	       if Y==Xi then
		  {RemoveDrone T Xi N}
	       else
		  Point|{RemoveDrone T Xi N}
	       end
	    end
	 end
      end
   end

   %enlève les points qui n'ont ni X ni Y en commun avec sonar
   fun{RemoveSonar L Xs Ys} %testée et approuvée
      local X Y Point in
	 case L of nil then nil
	 [] H|T then
	    X=H.x
	    Y=H.y
	    Point=pt(x:X y:Y)
	    if X==Xs then
	       Point|{RemoveSonar T Xs Ys}
	    elseif Y==Ys then
	       Point|{RemoveSonar T Xs Ys}
	    else
	       {RemoveSonar T Xs Ys}
	    end
	 end
      end
   end

   %crée une liste allant de N à 1
   fun{Lista N}
      if N==0 then nil
      else N|{Lista N-1}
      end
   end

   %pour savoir combien de fois A est dans L
   fun{MaxIteration L A}
      local MaxIteration2 in
	 fun{MaxIteration2 L A C}
	    case L of nil then C
	    [] H|T then
	       if H==A then {MaxIteration2 T A C+1}
	       else {MaxIteration2 T A C}
	       end
	    end
	 end
	 {MaxIteration2 L A 0}
      end
   end

   %faire une liste avec tous les points en X ou en Y d'une liste de point
   fun{ListOfPoint L I}
      case L of nil then
	 nil
      []H|T then
	 if I==0 then
	    H.x|{ListOfPoint T I}
	 else
	    H.y|{ListOfPoint T I}
	 end
      end
   end

   %fct pour trouver quel est le X ou le Y qui se retrouve le plus dans les positions possibles de l'adversaire (pour placer un missile/drone)
   fun{Drone List}
      local List0 List1 List2 List3 Drone2 Res1 Res2 in
	 List0={ListOfPoint List 0} %liste tous avec les points
	 List1={ListOfPoint List 1}
	 List2={Lista Input.nRow}
	 List3={Lista Input.nColumn}
	 fun{Drone2 L L2 C A}
	    case L2 of nil then d(count:C coo:A) %on renvoie la coordonnée et son nombre d'itérations
	    [] H|T then
	       if({MaxIteration L H}>C) then
		  {Drone2 L T {MaxIteration L H} H}
	       else
		  {Drone2 L T C A}
	       end
	    end
	 end
	 Res1={Drone2 List0 List2 0 0}
	 Res2={Drone2 List1 List3 0 0}
	 if Res1.count<Res2.count then
	    drone(column Res2.coo)
	 else
	    drone(row Res1.coo)
	 end
      end
   end

   % Cette fonction sert pour savoir si oui ou non la Direction est possible à la position pt(x:X y:Y) sur la Input.map
   fun{Where Direction X Y}%validée
      local CandPos in
	 case Direction of east then CandPos=pt(x:X y:Y+1)
	 [] south then CandPos=pt(x:X+1 y:Y)
	 [] west then CandPos=pt(x:X y:Y-1)
	 [] north then CandPos=pt(x:X-1 y:Y)
   [] surface then CandPos=pt(x:X y:Y)
	 end
	 CandPos
      end
   end

    %Pour voir si la position est dans la map et dans l'eau
   fun{IsValidPathEnemy E} %validée
      local X Y in
	 pt(x:X y:Y)=E
	 (X >= 1 andthen X =< Input.nRow andthen Y >= 1 andthen Y =< Input.nColumn) andthen {IsIsland Input.map X Y} == 0
      end
   end

   fun {SayMove ID Direction State}
      {System.show saymovefunction}
      {System.show ID}
      local SayMove2 in
	 fun{SayMove2 L}
	    case L of nil then nil
	    [] pt(x:X y:Y)|T then
	       if {IsValidPathEnemy {Where Direction X Y}}==true then
		  {Where Direction X Y}|{SayMove2 T}
	       else
		  {System.show jesuispasici}
		  {SayMove2 T}
	       end
	    end
	 end
	 {SayMove2 State.ID.potPos}
      end
   end

   proc {SaySurface ID}
      {System.show saySurface}
   end

   proc{SayCharge ID KindItem} % proc pcq on retourne rien?
      {System.show sayCharge}
   end

   proc{SayMinePlaced ID}% proc pcq on retourne rien?
      {System.show sayMinePlaced}
   end

   fun{SayMissileExplode ID Position ?Message State}%simon

      if Position.y==State.pos.y andthen Position.x==State.pos.x then
	 if (State.life < 3 )then
	    Message=sayDeath(State.id)
	    {Record.adjoin State player(life:0)}

	 else
	    Message=sayDamageTaken(State.id 2 State.life-2)
	    {Record.adjoin State player(life:State.life-2)}
	 end
      else
	 if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
	    if State.life < 2 then
	       Message=sayDeath(State.id)
	       {Record.adjoin State player(life:0)}

	    else
	       Message=sayDamageTaken(State.id 1 State.life-1)
	       {Record.adjoin State player(life:State.life-1)}

	    end
	 else
      Message=null
	    State
	 end
      end
   end

   fun{SayMineExplode ID Position ?Message State}%simon
      if Position.y==State.pos.y andthen Position.x==State.pos.x then
	 if (State.life < 3 )then
	    {Record.adjoin State player(life:0)}
	    Message=sayDeath(State.id)
	 else
      Message=sayDamageTaken(State.id 2 State.life-2)
	    {Record.adjoin State player(life:State.life-2)}
	 end
      else
	 if (({Number.abs Position.y-State.pos.y}+{Number.abs Position.x-State.pos.x})<2) then
	    if State.life < 2 then
	       {Record.adjoin State player(life:0)}
	       Message=sayDeath(State.id)
	    else
          Message=sayDamageTaken(State.id 1 State.life-1)
	       {Record.adjoin State player(life:State.life-1)}
	    end
	 else
   Message=null
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

   fun{SayAnswerDrone ID Drone Answer State}
      case Drone of drone(row X) then
	 if Answer==false then
	    {System.show sayanswerdrone1}
	    {RemoveDrone State.ID.potPos X 2}
	 else
	    {System.show sayanswerdrone3}
	    {RemoveDrone State.ID.potPos X 1}
	 end
      [] drone(column Y) then
	 if Answer==false then
	    {System.show sayanswerdrone2}
	    {RemoveDrone State.ID.potPos Y 4}
	 else
	    {System.show sayanswerdrone4}
	    {RemoveDrone State.ID.potPos Y 3}
	 end
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


   fun{InverseList L}
      case L of nil then nil
      [] H|T then
	 case H of east then west|{InverseList T}
	 [] west then east|{InverseList T}
	 [] south then north|{InverseList T}
	 [] north then south|{InverseList T}
	 end
      end
   end

   fun{Move ?Position ?Direction State}
      {System.show newmove}
      if(State.nbMove==1) then
    Direction=surface
	 Position=State.pos
	 {Record.adjoin State player(n:1 nbMove:5 immersed:false path:nil dir:nil dir2:{InverseList State.dir})}
      elseif(State.n==0) then
	 local ListPosDir in
	    ListPosDir =  {GetNewPos State [east north west south]}
	    if ListPosDir==nil then
          Direction=surface
          Position=State.pos
	       {Record.adjoin State player(n:0 nbMove:5 immersed:false path:nil dir:nil)}
	    else
	    Position=ListPosDir.1
	    Direction=ListPosDir.2
	    {Record.adjoin State player(pos:Position nbMove:State.nbMove-1 path:Position|State.path dir:Direction|State.dir)}
end
   end
      else
	 local Pos in
	    Direction=State.dir2.1
	    case Direction of east then Pos=pt(x:State.pos.x y:State.pos.y+1)
	    [] south then Pos=pt(x:State.pos.x+1 y:State.pos.y)
	    [] west then Pos=pt(x:State.pos.x y:State.pos.y-1)
	    [] north then Pos=pt(x:State.pos.x-1 y:State.pos.y)
	    end
	    Position=Pos
	    {Record.adjoin State player(pos:Pos nbMove:State.nbMove-1 path:Pos|State.path dir:Direction|State.dir dir2:State.dir2.2)}
	 end
      end
   end

   fun{ChargeItem ?KindItem State}
      {System.show chargeitem}
      {System.show State.item}
      local PosItem ChargeItem2 in
	 fun{ChargeItem2 TempItem}
	    {System.show TempItem}
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
	 if(State.item==0) then
	    {ChargeItem2 sonar}
	 elseif(State.item==1) then
	    {ChargeItem2 drone}
	 else
	    {ChargeItem2 missile}
	 end
      end
   end

   %choisis quelle item a launch , coder IA ici et fireItem fait la logistique
   fun {ValidItem ListFire State}
   {System.show validitem}
   {System.show ListFire}
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

   fun{FireItem ID ?KindFire State} % Listfire étrange? version smart buggé donc remplacé par tout con , peut etre trouvée au commit updateplayer du 20/4
      local Fire in
	 Fire={ValidItem [sonar drone missile mine rien]  State}.1
	 {System.show youBurnWithUs}
	 {System.show Fire}
	 case Fire of mine then
	    KindFire=mine(State.pos)
	    {Record.adjoin State player(listMine:KindFire|State.listMine numberMine:State.numberMine-1)}

	 [] missile then
      KindFire=missile({FindInList State.ID.potPos {Random {List.length State.ID.potPos}}})
	    {Record.adjoin State player(numberMissile:State.numberMissile-1)}

	 [] drone then
	    KindFire={Drone State.ID.potPos} % nrow bugged? remplaced by 8 for the time being
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
      {System.show firemine}
      {System.show State.listMine}
      if State.listMine==nil then
	 Mine=null
	 State
      else
	 {System.show fireMine2}
	 Mine=State.listMine.1.1 %first object first argument (which is position)
	 {Record.adjoin State player(listMine:{RemoveFromList State.listMine State.listMine.1})}
      end
   end

   fun {CreatePlayer T State} %T est remplacé par Input.nbPlayer
      {System.show t}
      {System.show T}
      {System.show state}
      {System.show State}
      if T==0 then State
      elseif (T==State.id.id) then {CreatePlayer T-1 State}
      else
        local Newstate in
          Newstate={Record.adjoin State player(T:id(potPos:{TournerMap 1} life:Input.maxDamage))}
          {System.show newstate}
          {System.show Newstate}
          {CreatePlayer T-1 Newstate}
          end
      end
   end

   fun {FindValidTarget State}
    local Secondfun Acc in
       fun {Secondfun State Acc}
           if Acc==State.id.id then {Secondfun State Acc+1}
           else
              if Acc>Input.nbPlayer then {System.show 'pas trouvé de cible , error'} null
              else
                  if State.Acc.life > 0 then Acc
                  else  {Secondfun State Acc+1}
                  end
              end
           end
        end
        {Secondfun State 1}
    end
end

   fun{StartPlayer Color ID}
      Stream
      Port
      PlayerState
      Newstate
   in
      {System.show bite}
      %immersed pour savoir si il est en surface ou pas
      PlayerState = player(id:id(id:ID color:Color name:fishy) item:0 path:nil dir:nil n:0 dir2:nil nbMove:5 pos:nil immersed:false life:Input.maxDamage listMine:nil loadMine:0 numberMine:0 listMissile:nil loadMissile:0 numberMissile:0 loadDrone:0 numberDrone:0 loadSonar:0 numberSonar:0)
      {NewPort Stream Port}
      Newstate={CreatePlayer Input.nbPlayer PlayerState}
      thread
	 {System.show start_playfdp}
	 {TreatStream Stream Newstate}
      end
      Port
   end

   proc {TreatStream Stream State}
      {System.show stream}
      {System.show Stream}

      {System.show state}
      {System.show State}

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
	    Newstate={FireItem {FindValidTarget State} ?KindFire  State}
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
	 {System.show Answer}
	 {TreatStream T State}

      [] sayMove(ID Direction)|T then
      {System.show ID.id}
      {System.show State.id}
      {System.show sayMove}
      if ID.id==State.id.id then
      {System.show queue}
      {TreatStream T State}
      else

	 local Newstate Var in
      Var=ID.id
      {System.show itsthevar}
      {System.show Var}
	    Newstate={Record.adjoin State player(Var:id(potPos:{SayMove Var Direction State} life:State.Var.life))}
	    {System.show saymooove_done}
	    {TreatStream T Newstate}
      end
	 end

      [] saySurface(ID)|T then
	 {System.show saySurface}
	 {SaySurface ID}
	 {TreatStream T State}

      [] sayCharge(ID KindItem)|T then {SayCharge ID KindItem}
	 {System.show sayCharge_done}
	 {TreatStream T State}

      [] sayMinePlaced(ID)|T then
	 {System.show sayMinePlaced}
	 {SayMinePlaced ID}
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
      if ID.id==State.id.id then
      {TreatStream T State}
      else
	 {System.show sayAnswerDrone1}
	 local Newstate Var in
      Var=ID.id
	    Newstate={Record.adjoin State player(Var:id(potPos:{SayAnswerDrone Var Drone Answer State} life:State.Var.life))}
	    {System.show benIsAGod}
	    {System.show sayAnswerDrone2}
	    {TreatStream T Newstate}
	 end
   end
      [] sayPassingDrone(Drone ?ID ?Answer)|T then
	 {System.show sayPassingDrone1}
	 ID=State.id
	 Answer={SayPassingDrone Drone State}
	 {System.show sayPassingDrone2}
	 {TreatStream T State}

      [] sayAnswerSonar(ID Answer)|T then
      if ID.id==State.id.id then {TreatStream T State}
      else
	 {System.show sayAnswerSonar1}
	 local Newstate Var in
      Var=ID.id
	    Newstate={Record.adjoin State player(Var:id(potPos:{RemoveSonar State.Var.potPos Answer.x Answer.y} life:State.Var.life))}
	    {System.show sayAnswerSonar2}
	    {TreatStream T Newstate}
	 end
   end
      [] sayPassingSonar(?ID ?Answer)|T then
	 {System.show sayPassingSonar1}
	 ID=State.id
	 Answer={SayPassingSonar State}
	 {System.show sayPassingSonar2}
	 {TreatStream T State}

      [] sayDeath(ID)|T then
      if ID.id==State.id.id then {TreatStream T State}
      else
	 {System.show isLaMort1}
	 local Newstate Var in
	    Newstate={Record.adjoin State player(Var:id(potPos:State.Var.potPos life:0))}
	    {System.show isLaMort2}
	    {TreatStream T Newstate}
	 end
   end

      [] sayDamageTaken(ID Damage LifeLeft)|T then %dégats des ennemis seulement
      if ID.id==State.id.id then {TreatStream T State}
      else
	 {System.show isLesDegats1}
	 local Newstate Var in
      Var=ID.id
	    Newstate={Record.adjoin State player(Var:id(potPos:State.Var.posPot life:LifeLeft))}
	    {System.show isLesDegats2}
	    {TreatStream T Newstate}
	 end
   end

      else
	 {System.show noMatchingInTreatStream}
	 {System.show Stream}

      end
   end
end
% enlevé tout les {{...} State } ... smart?
