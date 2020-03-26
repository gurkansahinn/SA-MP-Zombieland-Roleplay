#include <a_samp>
#include <FCNPC>

public OnFilterScriptInit()
{
	new test = FCNPC_Create("test");
	FCNPC_Spawn(test, 93, 0.0, 0.0, 1.0);
	return 1;
}