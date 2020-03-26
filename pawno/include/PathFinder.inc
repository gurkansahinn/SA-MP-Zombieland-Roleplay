#if defined PathFinder
  #endinput
#endif
#define PathFinder
native PathFinder_Init(mapAndreasAddress, threads = 1);
native PathFinder_FindWay(routeid, Float:startX, Float:startY, Float:endX, Float:endY, Float:zDifference = 0.9, stepSize = 1, stepLimit = -1, maxSteps = 2000);
native PathFinder_SetTickRate(rate = 10);
native PathFinder_MapAndreasLock();
native PathFinder_MapAndreasUnlock();
forward OnPathCalculated(routeid, success, Float:nodesX[], Float:nodesY[], Float:nodesZ[], nodesSize);                                                                                  