defmodule Project2 do
  use GenServer
  use Application

  def test(nodesNum,top,algo) do
      algo =
        if algo == "gossip" do
          :gossip
        else
          if algo == "pushsum" do
            :pushsum
          else
            IO.puts "Invalid algo"
            System.halt(1)
          end
        end
      nodesNum =
      if top == "rand2D" || top == "sphere" do          #'getting the closest perfect square'
                   :math.sqrt(nodesNum)
                   |>round
                   |>:math.pow(2)

      else
        nodesNum =
        if top == "3D" do
                    :math.pow(nodesNum,1/3)
                    |>round
                    |>:math.pow(3)
                    |> round
        else
          nodesNum
        end
        nodesNum
      end

      nodes = Enum.map((1..round(nodesNum)), fn(x)->
        pid = createNodes(algo)   #getting pid and starting the node'
        upPidSt(algo,pid,x)   #'updating the state of the pid'
        pid
      end)
      counter = :ets.new(:counter,[:named_table,:public])    #creating a master counter to count no of nodes which have received rumor
      :ets.insert(counter,{"ct",0})         #initiating counter to zero
      buildTop(top,nodes,algo);                    #building topologies
      sTime = System.monotonic_time(:milliseconds)    #start time of algorithm

      startAlgo(algo,nodes,sTime,nodesNum)     #starting the algo gossip or pushsum depending on input
      infiniteloop()          #creating an infinite loop so that our program doesn't end without full convergence

  end





  def buildTop(top,nodes,algo) do   #selecting topology to build
    case top do
      "full"   -> topFull(algo,nodes)
      "3D"     -> top3D(algo,nodes)
      "rand2D" -> topRand2D(algo,nodes)
      "sphere" -> topSphere(algo,nodes)
      "line"   -> topline(algo,nodes)
      "imp2D"  -> topImp2D(algo,nodes)
      true-> IO.puts "Invalid Topology"
      System.halt(1)
    end
  end
  def topFull(algo,nodes) do   # implementing fully connected topology
    Enum.each(nodes, fn(a) ->
      adjacentlist = List.delete(nodes,a)
      upAdLs(a,algo,adjacentlist)
    end)
  end
  def top3D(algo,nodes) do
    num = Enum.count(nodes)
    numRoot = round(:math.pow(num, 1/3))
    Enum.each(nodes, fn(i)->
      ind = Enum.find_index(nodes,fn(x)->x==i end)
      ls = []
      level = trunc(ind/(numRoot*numRoot))
      ls =
      if ((ind - numRoot) >= (level*numRoot*numRoot)) do  # up
          ls ++ [Enum.fetch!(nodes,ind - numRoot)]
      else
        ls
      end
      ls =
      if ((ind + numRoot) < ((level+1)*numRoot*numRoot)) do  # down
          ls ++ [Enum.fetch!(nodes,ind + numRoot)]
      else
        ls
      end
      ls =
      if ((rem((ind - 1),numRoot) != (numRoot - 1)) && ((ind - 1) >= 0)) do  # left
        ls ++ [Enum.fetch!(nodes,ind - 1)]
      else
        ls
      end
      ls =
      if (rem((ind + 1),numRoot) != 0) do  # right
        ls ++ [Enum.fetch!(nodes,ind + 1)]
      else
        ls
      end
      ls =
      if ((ind + (numRoot*numRoot)) < num) do  # front
        ls ++ [Enum.fetch!(nodes,ind + (numRoot*numRoot))]
      else
        ls
      end
      ls =
      if (ind - (numRoot*numRoot) >= 0) do  # back
        ls ++ [Enum.fetch!(nodes,ind - (numRoot*numRoot))]
      else
        ls
      end
      upAdLs(i,algo,ls)
    end)
  end
def topRand2D(algo,nodes) do
    num = Enum.count(nodes)
    numSqr = :math.sqrt num
    Enum.each(nodes, fn(i)->
      ind = Enum.find_index(nodes,fn(x)->x==i end)
      ls = []
        ls =
        if (ind < (num - (numSqr))) do  # checking for bottom row
          tempInd = ind + round(numSqr)
          ls ++ [Enum.fetch!(nodes,tempInd)]
        else
          ls
        end

        ls =
        if (ind >= numSqr) do  # checking for top row
          tempInd = ind - round(numSqr)
          ls ++ [Enum.fetch!(nodes,tempInd)]
        else
          ls
        end

        ls =
        if (rem(ind, round(numSqr)) != 0) do  # checking for left row
           ls ++ [Enum.fetch!(nodes,ind - 1)]
        else
          ls
        end
        ls =
        if (rem(ind + 1, round(numSqr)) != 0) do  # checking for right row
           ls ++ [Enum.fetch!(nodes,ind + 1)]
        else
          ls
        end
        li = Enum.random(nodes)
        ls = ls++[li]

      upAdLs(i,algo,ls)
    end)
  end
  def topSphere(algo,nodes) do
    num = Enum.count(nodes)
    numSqr = :math.sqrt num
    Enum.each(nodes, fn(i)->
      ind = Enum.find_index(nodes,fn(x)->x==i end)
      ls = []
      ls =
      if (ind < (num - (:math.sqrt num)) ) do  # checking for bottom row
          tempInd = ind + round(numSqr)
          ls ++ [Enum.fetch!(nodes,tempInd)]
      else
          tempInd = rem(ind + round(numSqr), round(numSqr))
          ls ++ [Enum.fetch!(nodes,tempInd)]
      end
      ls =
      if (ind >= :math.sqrt num) do  # checking for top row
          tempInd = ind - round(numSqr)
          ls ++ [Enum.fetch!(nodes,tempInd)]
      else
          tempInd = ind + (num - round(numSqr))
          ls ++ [Enum.fetch!(nodes,tempInd)]
      end
      ls =
      if (rem(ind, round(:math.sqrt(num))) != 0) do  # checking for left row
          ls ++ [Enum.fetch!(nodes,ind - 1)]
      else
          ls ++ [Enum.fetch!(nodes,ind + round(numSqr) - 1)]
      end
      ls =
      if (rem(ind + 1, round(:math.sqrt(num))) != 0) do  # checking for right row
          ls ++ [Enum.fetch!(nodes,ind + 1)]
      else
          ls ++ [Enum.fetch!(nodes,ind - round(numSqr) - 1)]
      end
      upAdLs(i,algo,ls)
    end)
  end
  def topline(algo,nodes) do     # implementing line topology
     num = Enum.count(nodes)
     Enum.each(nodes, fn(i)->
     ind = Enum.find_index(nodes,fn(x)->x==i end)
     ls =
     cond  do
      ind == 0 ->
         [Enum.fetch!(nodes,1)]
      num == ind+1 ->
         [Enum.fetch!(nodes,ind-1)]
      true ->
        [Enum.fetch!(nodes,ind-1),Enum.fetch!(nodes,ind+1)]
      end

      upAdLs(i,algo,ls)

     end)
  end
  def topImp2D(algo,nodes) do    #implementing imperfect line topology
      num = Enum.count(nodes)
      Enum.each(nodes, fn(i)->
      ind = Enum.find_index(nodes,fn(x)->x==i end)
      list = List.delete(nodes,i)
      ls =
      cond do
      ind == 0 ->
         list = List.delete(list,Enum.fetch!(nodes,1))
         [Enum.fetch!(nodes,1),Enum.random(list)]
      num == ind+1 ->
         list = List.delete(list,Enum.fetch!(nodes,ind-1))
         [Enum.fetch!(nodes,ind-1),Enum.random(list)]
      true ->
        list = List.delete(list,Enum.fetch!(nodes,ind-1))
        list = List.delete(list,Enum.fetch!(nodes,ind+1))
        [Enum.fetch!(nodes,ind-1), Enum.fetch!(nodes,ind+1), Enum.random(list)]
      end

      upAdLs(i,algo,ls)

     end)
  end

  def startAlgo(:gossip,nodes,sTime,max) do  #starting gossip algo
    fnode = Enum.random(nodes)      #chosing the First node
    upCtSt(fnode,sTime,max)       #updating it's counter
    #spawn(Project2,:rumor,[fnode,sTime,max]);
    gossipStart(fnode,sTime,max)    #starting rumor
  end

  def startAlgo(:pushsum,nodes,sTime,max) do   # starting push sum algo
      randomNode = Enum.random(nodes)
      GenServer.cast(randomNode,{:pushsum,0,0,sTime,max})
  end

  def gossipStart(chosenNodes,sTime,max) do    #rumor spreading
    counter = getCounter(chosenNodes)
    if counter < 10 do
        adjList = getAdjList(:gossip,chosenNodes)
        randomNode = Enum.random(adjList)
        c = getCounter(randomNode)
        if c == 0 do
        Task.start(Project2,:rumor,[randomNode,sTime,max])
        else
        upCtSt(randomNode,sTime,max)
        end
        gossipStart(chosenNodes,sTime,max)
    else
        Process.exit(chosenNodes,:normal)
    end
    gossipStart(chosenNodes,sTime,max)
  end
  def rumor(node,sTime,max) do
      upCtSt(node,sTime,max)
      gossipStart(node,sTime,max)
  end

  def getCounter(node) do
    GenServer.call(node,{:counter})
  end

  def getAdjList(algo,node) do
      GenServer.call(node,{:adjList,algo})
  end

  def upCtSt(node,sTime,max) do
      GenServer.call(node, {:upCtSt,sTime,max})
  end


  def handle_cast({:pushsum,incS,incW,sTime,max},state) do
    {id,counter,s,w,list} = state

    s1 = s + incS
    w1 = w + incW

    diff = abs((s1/w1)-(s/w))
    if( (diff < :math.pow(10,-10)) && (counter==2) ) do
      ct = :ets.update_counter(:counter,"ct",{2,1})
      if(ct == max) do
        endt = System.monotonic_time(:millisecond) - sTime
        IO.puts "convergence in = #{endt} millisec   #{sTime}  #{System.monotonic_time(:millisecond)}"
        System.halt(1)
      end
    end

    counter =
    if(diff < :math.pow(10,-10) && counter<2) do
      counter+1
    else
      counter
    end

    counter =
    if(diff > :math.pow(10,-10)) do
       0
    else
      counter
    end
    state = {id,counter,s1/2,w1/2,list}
    rdNode = Enum.random(list)
    pushSum(rdNode,s1/2,w1/2,sTime,max)
    {:noreply,state}
  end

  def pushSum(node,incS,incW,sTime,max) do
    GenServer.cast(node,{:pushsum,incS,incW,sTime,max})
  end

  def upPidSt(algo,pid,id) do
    GenServer.call(pid,{:upPidSt,algo,id})
  end

  def upAdLs(node,algo,list) do
    GenServer.call(node,{:update,algo,list})
  end

  def handle_call({:update,:gossip,list},_from,state) do
    {a,b,_c} = state
    state = {a,b,list}
    {:reply,a,state}
  end

  def handle_call({:update,:pushsum,list},_from, state) do
    {a,b,c,d,_e} = state
    state = {a,b,c,d,list}
    {:reply,a,state}
  end

  def handle_call({:counter},_from,state) do
    {_a,b,_c} = state
    {:reply,b,state}
  end
  def handle_call({:adjList,:gossip},_from,state) do
    {_a,_b,c} = state
    {:reply,c,state}
  end

  def handle_call({:adjList,:pushsum},_from,state) do
    {_a,_b,_c,_d,e} = state
    {:reply,e,state}
  end

  def handle_call({:upCtSt,sTime,max},_from,state) do
    {a,b,c} = state
    if b == 0 do
      ct = :ets.update_counter(:counter,"ct",{2,1})
      if(ct == max) do
        endt = System.monotonic_time(:millisecond) - sTime
        IO.puts "rumor spread in = #{endt} millisec"
        System.halt(1)
      end
    end
  state = {a,b+1,c}
  {:reply,b,state}
  end


  def handle_call({:upPidSt,:gossip,id},_from, state) do   #updating the id's of created nodes
    {a,b,c} = state
    state = {id,b,c}
    {:reply,a,state}
  end

  def handle_call({:upPidSt,:pushsum,id},_from,state) do    #updating the id's and s of nodes
    {a,b,_c,d,e} = state
    state = {id,b,id,d,e}
    {:reply,a,state}
  end

  def createNodes(:gossip) do   # creating nodes for push sum algo
    {:ok,pid} = GenServer.start_link(__MODULE__,:gossip,[])
    pid
  end

  def createNodes(:pushsum) do   # creating nodes for push sum algo
    {:ok,pid} = GenServer.start_link(__MODULE__,:pushsum,[])
    pid
  end

  def init(:gossip) do
    {:ok,{0,0,[]}}  # id,counter,adjacentlist
  end

  def init(:pushsum) do
    {:ok,{0,0,0,1,[]}}   #id,counter,s,w, adjacentlist
  end

  def infiniteloop() do
    infiniteloop()
  end

  def start(_,_) do
    [a,b,c] = System.argv()
    Project2.test(String.to_integer(a),b,c)

  end

end




