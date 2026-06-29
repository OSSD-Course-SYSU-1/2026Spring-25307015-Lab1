import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { AlarmManager, BreakpointManager } from '../models/Alarm';
import { DistributedDataManager } from '../models/DistributedDataManager';
import { AlarmService } from '../services/AlarmService';
import { ContinuationManager } from '../services/ContinuationManager';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    try {
      this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    } catch (err) {
      hilog.error(DOMAIN, 'testTag', 'Failed to set colorMode. Cause: %{public}s', JSON.stringify(err));
    }
    
    // Initialize alarm manager
    AlarmManager.init();
    
    // Initialize breakpoint manager for responsive design
    BreakpointManager.init();
    
    // Initialize distributed data manager for cross-device synchronization
    DistributedDataManager.getInstance().init();
    
    // Initialize alarm service for background notifications
    AlarmService.getInstance().start();
    
    // Initialize continuation manager for cross-device migration
    ContinuationManager.getInstance().init();
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    // Stop alarm service
    AlarmService.getInstance().stop();
    
    // Cleanup continuation manager
    // ContinuationManager cleanup handled by garbage collection
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    // Restart alarm service if needed
    AlarmService.getInstance().start();
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    // Alarm service continues running in background
    
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}