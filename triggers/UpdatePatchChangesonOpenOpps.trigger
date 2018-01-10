trigger UpdatePatchChangesonOpenOpps on Patch_Change__e (after insert) {
    TriggerDispatcher.run(new PatchChangeTriggerHandler());
}