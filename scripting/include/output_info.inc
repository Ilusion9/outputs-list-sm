#if defined _output_info_defined_
#endinput
#endif
#define _output_info_defined_

/**
 * Returns an output from an entity outputs list
 *
 * @param hammerId          Entity hammer id.
 * @param index             Index in the output list.
 * @param output            Buffer to copy the output name.
 * @param outputlen         Maximum size of the output buffer.
 * @param target            Buffer to copy the target name.
 * @param targetlen         Maximum size of the target buffer.
 * @param input             Buffer to copy the input received.
 * @param inputlen          Maximum size of the input buffer.
 * @param params            Buffer to copy the parameters received.
 * @param paramslen         Maximum size of the parameters buffer.
 * @param delay             Delay of the output
 * @param once              True if the output has 'Only Once' flag enabled.
 * @return                  True if the output has been returned.
 */
native bool GetHammerOutput(int hammerId, int index, char[] output, int outputlen, char[] target, int targetlen, char[] input, int inputlen, char[] params, int paramslen, float& delay, bool& once);

/**
 * Returns an output from an entity outputs list
 *
 * @param entity            Entity index.
 * @param index             Index in the output list.
 * @param output            Buffer to copy the output name.
 * @param outputlen         Maximum size of the output buffer.
 * @param target            Buffer to copy the target name.
 * @param targetlen         Maximum size of the target buffer.
 * @param input             Buffer to copy the input received.
 * @param inputlen          Maximum size of the input buffer.
 * @param params            Buffer to copy the parameters received.
 * @param paramslen         Maximum size of the parameters buffer.
 * @param delay             Delay of the output
 * @param once              True if the output has 'Only Once' flag enabled.
 * @return                  True if the output has been returned.
 */
native bool GetEntityOutput(int entity, int index, char[] output, int outputlen, char[] target, int targetlen, char[] input, int inputlen, char[] params, int paramslen, float& delay, bool& once);

/**
 * Returns the entity outputs count.
 *
 * @param hammerId          Entity hammer id.
 * @return                  The entity outputs count.
 */
native int GetHammerOutputsCount(int hammerId);

/**
 * Returns the entity outputs count.
 *
 * @param entity            Entity index.
 * @return                  The entity outputs count.
 */
native int GetEntityOutputsCount(int entity);

/* DO NOT EDIT BELOW THIS LINE */

public SharedPlugin __pl_output_info_defined_ = 
{
	name = "output_info",
	file = "output_info.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_output_info_SetNTVOptional()
{
	MarkNativeAsOptional("GetHammerOutput");
	MarkNativeAsOptional("GetEntityOutput");
	MarkNativeAsOptional("GetHammerOutputsCount");
	MarkNativeAsOptional("GetEntityOutputsCount");
}
#endif
