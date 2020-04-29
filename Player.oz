functor
import
   Input at 'Input.ozf'
   Browser(browse:Browse)
   Player at 'Player.ozf'
   OS
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

   %Added functions 
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
in
   /*
    * IsIsland is use to know what is at pt(x:X y:Y) on the Input.map (equal to L)
    */
   fun{IsIsland L X Y}
      local IsIsland2 in
	 fun{IsIsland2 M A}
	    if A==1 then M.1
	    else {IsIsland2 M.2 A-1}
	    end
	 end
	 {IsIsland2 {IsIsland2 L X} Y}
      end
   end

   /*
    * Histo check if E is not in L (to know if we have already been at the position E in the State.path (L))
    */
   fun{Histo L E} %testé et approuvé
      case L of nil then true
      [] H|T then
	 if H==E then false
	 else {Histo T E}
	 end
      end
   end

   /*
    * IsValidPath respond true if the position E is within the limits of the map, in the water and is not in the State.path (E)
    */
   fun{IsValidPath L E} %testé et approuvé
      local X Y in
	 pt(x:X y:Y)=E
	 (X >= 1 andthen X =< Input.nRow andthen Y >= 1 andthen Y =< Input.nColumn) andthen {IsIsland Input.map X Y} == 0 andthen {Histo L E}
      end
   end

   /*
    * Return a random number between 1 and N
    */
   fun {Random N}
      {OS.rand} mod N + 1
   end

   /*
    * Return a random position in the water
    */
   fun{RandomPosition M}
      local X Y in
	 X={Random Input.nRow}
	 Y={Random Input.nColumn}
	 if {IsIsland M X Y}==0 then pt(x:X y:Y)
	 else {RandomPosition M}
	 end
      end
   end

   /*
    * Return the Nth élément in the list L
    */
   fun {FindInList L N}
      if N==1 then L.1
      else {FindInList L.2 N-1}
      end
   end

   /*
    * Remove A from the list L
    */
   fun{RemoveFromList L A}
      case L of nil then nil
      [] H|T then
	 if H==A then {RemoveFromList T A}
	 else H|{RemoveFromList T A}
	 end
      end
   end

   /*
    * Create a list with all the potential position of the ennemy (all positions except those where there is an island)
    */
   fun{TournerMap K}
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

   /*
    * choose a random Direction in the list L and check if the Direction is valid
    * return the Position and Direction found
    */
   fun {GetNewPos State L}
      if L==nil then nil
      else
	 local CandPos CandDir PosDir in
	    CandDir={FindInList L {Random {List.length L}}} % pick a random Direction in the List L
	    case CandDir of east then CandPos=pt(x:State.pos.x y:State.pos.y+1)
	    [] south then CandPos=pt(x:State.pos.x+1 y:State.pos.y)
	    [] west then CandPos=pt(x:State.pos.x y:State.pos.y-1)
	    [] north then CandPos=pt(x:State.pos.x-1 y:State.pos.y)
	    end
            %check if CandPos is valid
	    if ({IsValidPath State.path CandPos}==true) then
	       PosDir=CandPos|CandDir %return the Position and the Direction
	    else
	       {GetNewPos State {RemoveFromList L CandDir}}
	    end
	 end
      end
   end

   /*
    * Remove all the "impossible" position of the ennemy after sending a drone
    * Li is the List of all the potential positions of the ennemy, Xi the answer of the drone and N is use to match the good case
    */
   fun{RemoveDrone Li Xi N}
      local Point X Y in
	 if N==1 then %Answer=true and row
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
	 elseif N==2 then %Answer=false and row
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
	 elseif N==3 then %Answer=true and column
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
	 else %Answer=false and column
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

   /*
    * Remove all the positions that have neither X nor Y in common with the sonar response
    */
   fun{RemoveSonar L Xs Ys}
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

   /*
    * Create a list from N to 1
    */
   fun{Lista N}
      if N==0 then nil
      else N|{Lista N-1}
      end
   end

   /*
    * Return the number of iteration of A in the list L
    */
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

   /*
    * Create a list with all the X-point of L (I==0) or the Y-point (I==1)
    */
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

   /*
    * Drone return the best column/row where to send a drone
    */
   fun{Drone List}
      local List0 List1 List2 List3 Drone2 Res1 Res2 in
	 List0={ListOfPoint List 0} %List with all the X-Point of the List
	 List1={ListOfPoint List 1} %List with all the Y-Point of the List
	 List2={Lista Input.nRow}
	 List3={Lista Input.nColumn}
	 fun{Drone2 L L2 C A}
	    case L2 of nil then d(count:C coo:A) %return the number of iteration and the column/row coordinate
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

   /*
    * To know if the Direction is good at the position pt(x:X y:Y) on the Input.map
    */
   fun{Where Direction X Y}
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

   /*
    * return true if is in the water and on the map
    */
   fun{IsValidPathEnemy E}
      local X Y in
	 pt(x:X y:Y)=E
	 (X >= 1 andthen X =< Input.nRow andthen Y >= 1 andthen Y =< Input.nColumn) andthen {IsIsland Input.map X Y} == 0
      end
   end

   /*
    * Delete of the impossible position of the ennemy (identified by ID) after he moved
    */
   fun {SayMove ID Direction State}
      local SayMove2 in
	 fun{SayMove2 L}
	    case L of nil then nil
	    [] pt(x:X y:Y)|T then
	       if {IsValidPathEnemy {Where Direction X Y}}==true then
		  {Where Direction X Y}|{SayMove2 T}
	       else
		  {SayMove2 T}
	       end
	    end
	 end
	 {SayMove2 State.ID.potPos}
      end
   end

   /*
    * Handle that the player identified has made a missile explode at the given position.
    */
   fun{SayMissileExplode ID Position ?Message State}
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
	    Message=sayDamageTaken(State.id 0 State.life)
	    State
	 end
      end
   end

   /*
    * Handle that the player identified has made a mine explode at the given position.
    */
   fun{SayMineExplode ID Position ?Message State}
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
	    Message=sayDamageTaken(State.id 0 State.life)
	    State
	 end
      end
   end

   /*
    * Answer the question given in the drone
    */
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

   /*
    * Coordinate the different case when a drone was sent
    */
   fun{SayAnswerDrone ID Drone Answer State}
      case Drone of drone(row X) then
	 if Answer==false then
	    {RemoveDrone State.ID.potPos X 2}
	 else
	    {RemoveDrone State.ID.potPos X 1}
	 end
      [] drone(column Y) then
	 if Answer==false then
	    {RemoveDrone State.ID.potPos Y 4}
	 else
	    {RemoveDrone State.ID.potPos Y 3}
	 end
      end
   end

   /*
    * Answer the question by giving a position with one coordinate right and the other wrong
    */
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

   /*
    * return the list with the opposite carddirection (when it's south, return north for example)
    */
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

   /*
    * Move the player at a right position
    */
   fun{Move ?Position ?Direction State}
      if(State.nbMove==1) then %surface and then do the reverse path
	 Direction=surface
	 Position=State.pos
	 {Record.adjoin State player(n:1 nbMove:5 immersed:false path:Position|nil dir:nil dir2:{InverseList State.dir})}
      elseif(State.n==0) then %at the beginning of the game
	 local ListPosDir in
	    ListPosDir =  {GetNewPos State [east north west south]} %choose a valid random position/direction
	    if ListPosDir==nil then %if there is no valid/random position (if the submarin is stuck)
	       Direction=surface
	       Position=State.pos
	       {Record.adjoin State player(n:0 nbMove:5 immersed:false path:Position|nil dir:nil)}
	    else
	       Position=ListPosDir.1
	       Direction=ListPosDir.2
	       {Record.adjoin State player(pos:Position nbMove:State.nbMove-1 path:Position|State.path dir:Direction|State.dir)}
	    end
	 end
      else %to do the reverse path
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

   /*
    * Charge : 1)sonar, 2)drone and 3)missiles (until the death of the ennemies) => we check the case 1 2 3 via the variable item
    */
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
	 if(State.item==0) then
	    {ChargeItem2 sonar}
	 elseif(State.item==1) then
	    {ChargeItem2 drone}
	 else
	    {ChargeItem2 missile}
	 end
      end
   end

   /*
    * Choose wich item to lauch (which one is valid)
    */
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

   /*
    * Fire the item
    */
   fun{FireItem ID ?KindFire State}
      local Fire in
	 Fire={ValidItem [sonar drone missile mine rien]  State}.1
	 case Fire of mine then
	    KindFire=mine(State.pos)
	    {Record.adjoin State player(listMine:KindFire|State.listMine numberMine:State.numberMine-1)}
	 [] missile then
	    KindFire=missile({FindInList State.ID.potPos {Random {List.length State.ID.potPos}}})
	    {Record.adjoin State player(numberMissile:State.numberMissile-1)}
	 [] drone then
	    KindFire={Drone State.ID.potPos}
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

   /*
    * Fire the first mine of the list listMine
    */
   fun{FireMine ?Mine State}
      if State.listMine==nil then
	 Mine=null
	 State
      else
	 Mine=State.listMine.1.1 %first object first argument (which is position)
	 {Record.adjoin State player(listMine:{RemoveFromList State.listMine State.listMine.1})}
      end
   end

   /*
    * Add to State a field in the record for each ennemy (id(potPos:{TournerMap 1} life:Input.maxDamage))
    */
   fun {CreatePlayer T State}
      if T==0 then State
      elseif (T==State.id.id) then {CreatePlayer T-1 State}
      else
	 local Newstate in
	    Newstate={Record.adjoin State player(T:id(potPos:{TournerMap 1} life:Input.maxDamage))}
	    {CreatePlayer T-1 Newstate}
	 end
      end
   end

   /*
    * The description is in the name
    */
   fun {FindValidTarget State}
      local Secondfun Acc in
	 fun {Secondfun State Acc}
	    if Acc==State.id.id then {Secondfun State Acc+1}
	    else
	       if Acc>Input.nbPlayer then null
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
      PlayerState = player(id:id(id:ID color:Color name:playerSmart) item:0 path:nil dir:nil n:0 dir2:nil nbMove:5 pos:nil immersed:false life:Input.maxDamage listMine:nil loadMine:0 numberMine:0 loadMissile:0 numberMissile:0 loadDrone:0 numberDrone:0 loadSonar:0 numberSonar:0)
      {NewPort Stream Port}
      Newstate={CreatePlayer Input.nbPlayer PlayerState}
      thread
	 {TreatStream Stream Newstate}
      end
      Port
   end

   proc {TreatStream Stream State}
      case Stream of nil then skip
      [] initPosition(?ID ?Position)|T then
	 ID=State.id
	 Position={RandomPosition Input.map}
	 local Newstate in
	    Newstate={Record.adjoin State player(pos:Position path:Position|nil)}
	    {TreatStream T Newstate}
	 end

      [] move(ID ?Position ?Direction)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={Move ?Position ?Direction State}
	    {TreatStream T Newstate}
	 end

      [] dive|T then
	 local Newstate in
	    Newstate={Record.adjoin State player(immersed:true)}
	    {TreatStream T Newstate}
	 end

      [] chargeItem(?ID ?KindItem)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={ChargeItem ?KindItem State}
	    {TreatStream T Newstate}
	 end

      [] fireItem(?ID ?KindFire)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={FireItem {FindValidTarget State} ?KindFire  State}
	    {TreatStream T Newstate}
	 end
      [] fireMine(?ID ?Mine)|T then
	 ID=State.id
	 local Newstate in
	    Newstate={FireMine ?Mine State}
	    {TreatStream T Newstate}
	 end
      [] isDead(?Answer)|T then
	 if State.life==0 then Answer=true
	 else Answer=false
	 end
	 {TreatStream T State}
      [] sayMove(ID Direction)|T then
	 if ID.id==State.id.id then
	    {TreatStream T State}
	 else
	    local Newstate Var in
	       Var=ID.id
	       Newstate={Record.adjoin State player(Var:id(potPos:{SayMove Var Direction State} life:State.Var.life))}
	       {TreatStream T Newstate}
	    end
	 end
      [] saySurface(ID)|T then
	 {TreatStream T State}
      [] sayCharge(ID KindItem)|T then
	 {TreatStream T State}
      [] sayMinePlaced(ID)|T then
	 {TreatStream T State}
      [] sayMissileExplode(ID Position ?Message)|T then %simon
	 local Newstate in
	    Newstate={SayMissileExplode ID.id Position Message State}
	    {TreatStream T Newstate}
	 end
      [] sayMineExplode(ID Position ?Message)|T then %simon
	 local Newstate in
	    Newstate={SayMineExplode ID.id Position Message State}
	    {TreatStream T Newstate}
	 end

      [] sayAnswerDrone(Drone ID Answer)|T then
	 if ID.id==State.id.id then
	    {TreatStream T State}
	 else
	    local Newstate Var in
	       Var=ID.id
	       Newstate={Record.adjoin State player(Var:id(potPos:{SayAnswerDrone Var Drone Answer State} life:State.Var.life))}
	       {TreatStream T Newstate}
	    end
	 end
      [] sayPassingDrone(Drone ?ID ?Answer)|T then
	 ID=State.id
	 Answer={SayPassingDrone Drone State}
	 {TreatStream T State}

      [] sayAnswerSonar(ID Answer)|T then
	 if ID.id==State.id.id then {TreatStream T State}
	 else
	    local Newstate Var in
	       Var=ID.id
	       Newstate={Record.adjoin State player(Var:id(potPos:{RemoveSonar State.Var.potPos Answer.x Answer.y} life:State.Var.life))}
	       {TreatStream T Newstate}
	    end
	 end
      [] sayPassingSonar(?ID ?Answer)|T then
	 ID=State.id
	 Answer={SayPassingSonar State}
	 {TreatStream T State}
      [] sayDeath(ID)|T then
	 if ID.id==State.id.id then {TreatStream T State}
	 else
	    local Newstate Var in
	       Var=ID.id
	       Newstate={Record.adjoin State player(Var:id(potPos:State.Var.potPos life:0))}
	       {TreatStream T Newstate}
	    end
	 end
      [] sayDamageTaken(ID Damage LifeLeft)|T then
	 if ID.id==State.id.id then {TreatStream T State}
	 else
	    local Newstate Var in
	       Var=ID.id
	       Newstate={Record.adjoin State player(Var:id(potPos:State.Var.potPos life:LifeLeft))}
	       {TreatStream T Newstate}
	    end
	 end
      end
   end
end
