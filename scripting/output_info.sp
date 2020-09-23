#include <sourcemod>
#include <regex>
#include <output_info>
#pragma newdecls required
#pragma dynamic 1048576

public Plugin myinfo =
{
	name = "Output Info",
	author = "Ilusion9",
	description = "Get entities outputs.",
	version = "1.0",
	url = "https://github.com/Ilusion9/"
};

enum
{
	Output = 0,
	Target,
	Input,
	Parameters,
	Delay,
	Once
};

enum struct EntityInfo
{
	int numOutputs;
	char outputsList[4096];
}

StringMap g_Map_Outputs;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	CreateNative("GetHammerOutput", Native_GetHammerOutput);
	CreateNative("GetEntityOutput", Native_GetEntityOutput);
	CreateNative("GetHammerOutputsCount", Native_GetHammerOutputsCount);
	CreateNative("GetEntityOutputsCount", Native_GetEntityOutputsCount);

	RegPluginLibrary("output_info");
}

public int Native_GetHammerOutput(Handle plugin, int numParams)
{
	char hammerBuffer[128];
	Format(hammerBuffer, sizeof(hammerBuffer), "%d", GetNativeCell(1));
	
	EntityInfo entInfo;
	if (!g_Map_Outputs.GetArray(hammerBuffer, entInfo, sizeof(EntityInfo))) // this entity has no outputs
	{
		return false;
	}
	
	int index = GetNativeCell(2);
	if (index < 0 || index >= entInfo.numOutputs) // invalid index received
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid output index %d", index);
	}
	
	char[][] splitOutputs = new char[entInfo.numOutputs][256];
	ExplodeString(entInfo.outputsList, "\n", splitOutputs, entInfo.numOutputs, 256);
	
	char splitParameters[6][128];
	ExplodeString(splitOutputs[index], "\e", splitParameters, sizeof(splitParameters), sizeof(splitParameters[]));
	
	if (!splitParameters[Target][0]) // no target
	{
		return false;
	}
	
	SetNativeString(3, splitParameters[Output], GetNativeCell(4));
	SetNativeString(5, splitParameters[Target], GetNativeCell(6));
	SetNativeString(7, splitParameters[Input], GetNativeCell(8));
	SetNativeString(9, splitParameters[Parameters], GetNativeCell(10));
	SetNativeCellRef(11, StringToFloat(splitParameters[Delay]));
	SetNativeCellRef(12, StringToInt(splitParameters[Once]) > 0);
	
	return true;
}

public int Native_GetEntityOutput(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
		
	char hammerBuffer[128];
	int hammerId = GetEntProp(entity, Prop_Data, "m_iHammerID");
	Format(hammerBuffer, sizeof(hammerBuffer), "%d", hammerId);
	
	EntityInfo entInfo;
	if (!g_Map_Outputs.GetArray(hammerBuffer, entInfo, sizeof(EntityInfo))) // this entity has no outputs
	{
		return false;
	}
	
	int index = GetNativeCell(2);
	if (index < 0 || index >= entInfo.numOutputs) // invalid index received
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid output index %d", index);
	}
	
	char[][] splitOutputs = new char[entInfo.numOutputs][256];
	ExplodeString(entInfo.outputsList, "\n", splitOutputs, entInfo.numOutputs, 256);
	
	char splitParameters[6][128];
	ExplodeString(splitOutputs[index], "\e", splitParameters, sizeof(splitParameters), sizeof(splitParameters[]));
	
	if (!splitParameters[Target][0]) // no target
	{
		return false;
	}
	
	SetNativeString(3, splitParameters[Output], GetNativeCell(4));
	SetNativeString(5, splitParameters[Target], GetNativeCell(6));
	SetNativeString(7, splitParameters[Input], GetNativeCell(8));
	SetNativeString(9, splitParameters[Parameters], GetNativeCell(10));
	SetNativeCellRef(11, StringToFloat(splitParameters[Delay]));
	SetNativeCellRef(12, StringToInt(splitParameters[Once]) > 0);
	
	return true;
}

public int Native_GetHammerOutputsCount(Handle plugin, int numParams)
{
	char hammerBuffer[128];
	Format(hammerBuffer, sizeof(hammerBuffer), "%d", GetNativeCell(1));
	
	EntityInfo entInfo;
	if (!g_Map_Outputs.GetArray(hammerBuffer, entInfo, sizeof(EntityInfo)))
	{
		return 0;
	}
	
	return entInfo.numOutputs;
}

public int Native_GetEntityOutputsCount(Handle plugin, int numParams)
{
	int entity = GetNativeCell(1);
	if (!IsValidEntity(entity))
	{
		return ThrowNativeError(SP_ERROR_NATIVE, "Invalid entity index %d", entity);
	}
		
	char hammerBuffer[128];
	int hammerId = GetEntProp(entity, Prop_Data, "m_iHammerID");
	Format(hammerBuffer, sizeof(hammerBuffer), "%d", hammerId);
	
	EntityInfo entInfo;
	if (!g_Map_Outputs.GetArray(hammerBuffer, entInfo, sizeof(EntityInfo)))
	{
		return 0;
	}
	
	return entInfo.numOutputs;
}

public void OnPluginStart()
{
	g_Map_Outputs = new StringMap();
}

public void OnMapEnd()
{
	g_Map_Outputs.Clear();
}

public Action OnLevelInit(const char[] mapName, char mapEntities[2097152])
{
	g_Map_Outputs.Clear();
	char hammerId[128];
	
	for (int current = 0, next = 0; (next = FindNextKeyChar(mapEntities[current], '}')) != -1; current += next)
	{
		char[] buffer = new char[next + 1];
		strcopy(buffer, next, mapEntities[current]);
		
		int pos = StrContains(buffer, "\"hammerid\" \"");
		if (pos == -1)
		{
			continue;
		}
		
		// get hammer id
		pos += 12;
		int end = FindCharInString(buffer[pos], '"');
		if (end != -1)
		{
			strcopy(hammerId, end + 1, buffer[pos]);
		}
		
		// get outputs
		char output[512];
		char parameters[512];
		char outputsList[sizeof(EntityInfo::outputsList)];
		EntityInfo entInfo;
		
		Regex outputMatch = new Regex("(\"On\\w*\") (\"[^\"]+\")");
		for (int i = pos + end + 1; outputMatch.Match(buffer[i]) > 0; i += outputMatch.MatchOffset())
		{
			outputMatch.GetSubString(1, output, sizeof(output));
			StripQuotes(output);
			
			// output validation
			if (CharToUpper(output[2]) != output[2])
			{
				continue;
			}
			
			outputMatch.GetSubString(2, parameters, sizeof(parameters));
			StripQuotes(parameters);
			
			entInfo.numOutputs++;
			if (outputsList[0])
			{
				Format(outputsList, sizeof(outputsList), "%s\n%s\e%s", outputsList, output, parameters);
			}
			else
			{
				Format(outputsList, sizeof(outputsList), "%s\e%s", output, parameters);
			}
		}

		if (entInfo.numOutputs)
		{
			strcopy(entInfo.outputsList, sizeof(EntityInfo::outputsList), outputsList);
			g_Map_Outputs.SetArray(hammerId, entInfo, sizeof(EntityInfo));
		}
		
		delete outputMatch;
	}
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
