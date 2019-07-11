### Group Members
- Rishabh Garg (_UFID_: **6649 9619**) ([Rishabh.Garg@ufl.edu](mailto:rishabh.garg@ufl.edu))
- Suhani Mehta (_UFID_: **4798 6909**) ([Suhani.Mehta@ufl.edu](mailto:suhani.mehta@ufl.edu))

### Execution Instructions
Traditional [mix](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html) structure is maintained. Execution script can be found at lib\proj2.exs

To execute, traverse to the directory containing _mix.exs_ file and execute `mix run lib\proj2.ex numNodes topology algorithm`.

Sample run: `mix run lib\proj2.exs 100 3D gossip`


### What is working
Convergence of **Gossip** Algorithm for all topologies
> Full<br />
> Line<br />
> Imperfect line<br />
> Random 2D<br />
> 3D<br />
> Torus<br />

Convergence of **Push Sum** Algorithm for all topologies
> Full<br />
> Line<br />
> Imperfect line<br />
> Random 2D<br />
> 3D<br />
> Torus<br />

### Largest Network: 
##### Gossip:

> Full topology: 5000(_nodes_)<br />
> Line topology: 2000<br />
> Imperfect Line topology: 20000<br />
> 3D topology: 15000<br />
> Sphere topology: 15000<br />
> Random2D topology: 20000 

##### Push-Sum:
> Full topology: 2000<br />
> Line topology: 300<br />
> Imperfect Line topology: 5000<br />
> 3D topology: 2000<br />
> Sphere topology: 1000<br />
> Random2D topology:  5000
