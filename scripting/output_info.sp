#include <sourcemod>
#include <regex>

#pragma newdecls required
#pragma dynamic 1048576

public Plugin myinfo =
{
	name = "Output Info",
	author = "Ilusion9",
	description = "Get entities outputs.",
	version = "1.1",
	url = "https://github.com/Ilusion9/"
};

enum struct OutputInfo
{
	char output[256];
	char target[256];
	char input[256];
	char params[256];
	float delay;
	bool once;
}

enum struct EntityInfo
{
	int numOutputs;
	int startIndex;
}

EngineVersion g_EngineVersion;
StringMap g_Map_Outputs;
ArrayList g_List_Outputs;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("GetHammerIdOutput", Native_GetHammerIdOutput);
	CreateNative("GetEntityOutput", Native_GetEntityOutput);
	CreateNative("GetHammerIdOutputsCount", Native_GetHammerIdOutputsCount);
	CreateNative("GetEntityOutputsCount", Native_GetEntityOutputsCount);

	RegPluginLibrary("output_info");
}

public int Native_GetHammerIdOutput(Handle plugin, int numParams)
{
	char hammerId[128];
	Format(hammerId, sizeof(hammerId), "%d", GetNativeCell(1));
	
	// no outputs
	EntityInfo entityInfo;
	if (!g_Map_Outputs.GetArray(hammerId, entityInfo, sizeof(EntityInfo)))
	{
		return false;
	}
	
	int outputIndex = GetNativeCell(2);
	if (outputIndex < 0 || outputIndex >= entityInfo.numOutputs)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid output index %d", outputIndex);
	}
	
	OutputInfo outputInfo;
	g_List_Outputs.GetArray(entityInfo.startIndex + outputIndex, outputInfo);
	
	// send output info
	SetNativeString(3, outputInfo.output, GetNativeCell(4));
	SetNativeString(5, outputInfo.target, GetNativeCell(6));
	SetNativeString(7, outputInfo.input, GetNativeCell(8));
	SetNativeString(9, outputInfo.params, GetNativeCell(10));
	SetNativeCellRef(11, outputInfo.delay);
	SetNativeCellRef(12, outputInfo.once);
	
	return true;
}

public int Native_GetEntityOutput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char hammerId[128];
	Format(hammerId, sizeof(hammerId), "%d", GetEntProp(entity, Prop_Data, "m_iHammerID"));
	
	// no outputs
	EntityInfo entityInfo;
	if (!g_Map_Outputs.GetArray(hammerId, entityInfo, sizeof(EntityInfo)))
	{
		return false;
	}
	
	int outputIndex = GetNativeCell(2);
	if (outputIndex < 0 || outputIndex >= entityInfo.numOutputs)
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid output index %d", outputIndex);
	}
	
	OutputInfo outputInfo;
	g_List_Outputs.GetArray(entityInfo.startIndex + outputIndex, outputInfo);
	
	// send output info
	SetNativeString(3, outputInfo.output, GetNativeCell(4));
	SetNativeString(5, outputInfo.target, GetNativeCell(6));
	SetNativeString(7, outputInfo.input, GetNativeCell(8));
	SetNativeString(9, outputInfo.params, GetNativeCell(10));
	SetNativeCellRef(11, outputInfo.delay);
	SetNativeCellRef(12, outputInfo.once);
	
	return true;
}

public int Native_GetHammerIdOutputsCount(Handle plugin, int numParams)
{
	char hammerId[128];
	Format(hammerId, sizeof(hammerId), "%d", GetNativeCell(1));
	
	// no outputs
	EntityInfo entityInfo;
	if (!g_Map_Outputs.GetArray(hammerId, entityInfo, sizeof(EntityInfo)))
	{
		return 0;
	}
	
	return entityInfo.numOutputs;
}

public int Native_GetEntityOutputsCount(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
	
	char hammerId[128];
	Format(hammerId, sizeof(hammerId), "%d", GetEntProp(entity, Prop_Data, "m_iHammerID"));
	
	// no outputs
	EntityInfo entityInfo;
	if (!g_Map_Outputs.GetArray(hammerId, entityInfo, sizeof(EntityInfo)))
	{
		return 0;
	}
	
	return entityInfo.numOutputs;
}

public void OnPluginStart()
{
	g_EngineVersion = GetEngineVersion();
	g_List_Outputs = new ArrayList(sizeof(OutputInfo));
	g_Map_Outputs = new StringMap();
}

public void OnMapEnd()
{
	g_List_Outputs.Clear();
	g_Map_Outputs.Clear();
}

public Action OnLevelInit(const char[] mapName, char mapEntities[2097152])
{
	g_List_Outputs.Clear();
	g_Map_Outputs.Clear();
	
	char hammerId[128];
	char output[256];
	char parameters[1024];
	EntityInfo entityInfo;
	OutputInfo outputInfo;
	Regex regexHammer = new Regex("(\"hammerid\") (\"[0-9]+\")");
	Regex regexOutput = new Regex("(\"On[A-Z]\\w*\") (\"[^\"]+\")");
	
	for (int current = 0, next = 0; (next = FindNextKeyChar(mapEntities[current], '}')) != -1; current += next)
	{
		// get entity keyvalues
		char[] buffer = new char[next + 1];
		strcopy(buffer, next, mapEntities[current]);
		
		// get hammerid
		if (regexHammer.Match(buffer) < 1)
		{
			continue;
		}
		
		regexHammer.GetSubString(2, hammerId, sizeof(hammerId));
		StripQuotes(hammerId);
		entityInfo.numOutputs = 0;
		
		// get outputs
		for (int i = 0; regexOutput.Match(buffer[i]) > 0; i += regexOutput.MatchOffset())
		{
			// get output name
			regexOutput.GetSubString(1, output, sizeof(output));
			StripQuotes(output);
			
			// get output params
			regexOutput.GetSubString(2, parameters, sizeof(parameters));
			StripQuotes(parameters);
			
			char splitParameters[5][256];
			ExplodeString(parameters, (g_EngineVersion != Engine_CSS) ? "\e" : ",", splitParameters, sizeof(splitParameters), sizeof(splitParameters[]));
			
			Format(outputInfo.output, sizeof(OutputInfo::output), output);
			Format(outputInfo.target, sizeof(OutputInfo::target), splitParameters[0]);
			Format(outputInfo.input, sizeof(OutputInfo::input), splitParameters[1]);
			Format(outputInfo.params, sizeof(OutputInfo::params), splitParameters[2]);
			outputInfo.delay = StringToFloat(splitParameters[3]);
			outputInfo.once = StringToInt(splitParameters[4]) > 0;
			
			g_List_Outputs.PushArray(outputInfo);
			entityInfo.numOutputs++;
		}
		
		if (entityInfo.numOutputs)
		{
			entityInfo.startIndex = g_List_Outputs.Length - entityInfo.numOutputs;
			g_Map_Outputs.SetArray(hammerId, entityInfo, sizeof(entityInfo));
		}
	}
	
	delete regexHammer;
	delete regexOutput;
}

int FindNextKeyChar(const char[] input, char key)
{
	int i;
	while (input[i] != key && input[i] != 0)
	{
		++i;
	}

	if (!input[i])
	{
		return -1;
	}
	
	return i + 2;
}
