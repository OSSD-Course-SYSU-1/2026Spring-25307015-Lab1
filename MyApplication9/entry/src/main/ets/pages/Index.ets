/**
 * Alarm Clock Main Page with responsive layout
 */
import { mediaquery } from '@kit.ArkUI';
import router from '@ohos.router';
import { AlarmList } from '../components/AlarmList';
import { ContinuationManager } from '../services/ContinuationManager';
import { Alarm } from '../models/Alarm';
import { AlarmData, DeviceInfo, AlarmDisplay } from '../models/types';

@Entry
@Component
struct Index {
  // Current time
  @State currentTime: string = this.getCurrentTime();
  @State currentDate: string = this.getCurrentDate();
  
  // Breakpoint for responsive design
  @StorageLink('currentBreakpoint') currentBreakpoint: string = 'sm';
  
  // Alarm data
  @StorageLink('alarms') alarmsData: AlarmData[] = [];
  
  // Next alarm
  @State nextAlarmTime: string = 'No alarm set';
  
  // Continuation (cross-device migration) state
  @State isDiscoveringDevices: boolean = false;
  @State discoveredDevices: DeviceInfo[] = [];
  @State isMigrating: boolean = false;
  @State migrationStatus: string = '';
  
  // Timer for updating current time
  private timerId: number = 0;
  private continuationManager: ContinuationManager = ContinuationManager.getInstance();
  
  // Initialize breakpoint manager
  aboutToAppear(): void {
    this.startTimeUpdate();
    this.updateAlarmsFromStorage();
    
    // Listen for breakpoint changes
    this.setupBreakpointListener();
    
    // Setup migration event listener
    this.setupMigrationListener();
  }
  
  aboutToDisappear(): void {
    this.stopTimeUpdate();
  }
  
  private startTimeUpdate(): void {
    this.timerId = setInterval(() => {
      this.currentTime = this.getCurrentTime();
      this.currentDate = this.getCurrentDate();
    }, 1000) as number;
  }
  
  private stopTimeUpdate(): void {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = 0;
    }
  }
  
  private getCurrentTime(): string {
    const now = new Date();
    const hours = now.getHours().toString().padStart(2, '0');
    const minutes = now.getMinutes().toString().padStart(2, '0');
    const seconds = now.getSeconds().toString().padStart(2, '0');
    return `${hours}:${minutes}:${seconds}`;
  }
  
  private getCurrentDate(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    const day = now.getDate().toString().padStart(2, '0');
    const weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const weekday = weekdays[now.getDay()];
    return `${year}-${month}-${day} ${weekday}`;
  }
  
  private updateAlarmsFromStorage(): void {
    // Alarms are already linked via @StorageLink
    this.updateNextAlarm();
  }
  
  private updateNextAlarm(): void {
    if (this.alarmsData && this.alarmsData.length > 0) {
      // Find the next enabled alarm
      const now = new Date();
      let nextAlarm: AlarmDisplay | null = null;
      let nextTime: Date | null = null;
      
      this.alarmsData.forEach((alarmData: AlarmData) => {
        if (alarmData.enabled) {
          const alarm = this.createAlarmFromData(alarmData);
          const alarmTime = alarm.nextAlarmTime();
          if (!nextTime || alarmTime < nextTime) {
            nextTime = alarmTime;
            nextAlarm = alarm;
          }
        }
      });
      
      if (nextAlarm && nextTime) {
        const hours = (nextTime as Date).getHours().toString().padStart(2, '0');
        const minutes = (nextTime as Date).getMinutes().toString().padStart(2, '0');
        this.nextAlarmTime = `Next: ${hours}:${minutes}`;
      } else {
        this.nextAlarmTime = 'No alarm set';
      }
    } else {
      this.nextAlarmTime = 'No alarm set';
    }
  }
  
  private createAlarmFromData(data: AlarmData): AlarmDisplay {
    // Create alarm object for display
    const hour = data.hour || 0;
    const minute = data.minute || 0;
    
    return {
      id: data.id,
      hour: hour,
      minute: minute,
      enabled: data.enabled || false,
      label: data.label || 'Alarm',
      repeatDays: data.repeatDays || [],
      nextAlarmTime: (): Date => {
        const now = new Date();
        const alarmTime = new Date();
        alarmTime.setHours(hour, minute, 0, 0);
        if (alarmTime <= now) {
          alarmTime.setDate(alarmTime.getDate() + 1);
        }
        return alarmTime;
      }
    };
  }
  
  private setupBreakpointListener(): void {
    // Set up media query listeners for breakpoints
    const smQuery = mediaquery.matchMediaSync('(320vp <= width < 600vp)');
    const mdQuery = mediaquery.matchMediaSync('(600vp <= width < 840vp)');
    const lgQuery = mediaquery.matchMediaSync('(840vp <= width < 1440vp)');
    const xlQuery = mediaquery.matchMediaSync('(width >= 1440vp)');

    smQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.currentBreakpoint = 'sm';
      }
    });

    mdQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.currentBreakpoint = 'md';
      }
    });

    lgQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.currentBreakpoint = 'lg';
      }
    });

    xlQuery.on('change', (result: mediaquery.MediaQueryResult) => {
      if (result.matches) {
        this.currentBreakpoint = 'xl';
      }
    });

    // Set initial breakpoint based on current width
    // This is a simplified approach - in a real app you would get the actual window width
    // For now, we'll default to 'sm' and let the media queries update it
  }
  
  private isMobile(): boolean {
    return this.currentBreakpoint === 'sm' || this.currentBreakpoint === 'xs';
  }
  
  private isTablet(): boolean {
    return this.currentBreakpoint === 'md' || this.currentBreakpoint === 'lg';
  }
  
  private isLargeScreen(): boolean {
    return this.currentBreakpoint === 'xl';
  }
  
  private addNewAlarm(): void {
    // Navigate to alarm edit page for adding new alarm
    router.pushUrl({
      url: 'pages/AlarmEdit/Index'
    }).catch((err: Error) => {
      console.error('Failed to navigate to add alarm page:', err);
    });
  }
  
  private toggleAlarm(alarmId: string): void {
    const updatedAlarms = this.alarmsData.map((alarm) => {
      if (alarm.id === alarmId) {
        return {
          id: alarm.id,
          hour: alarm.hour,
          minute: alarm.minute,
          enabled: !alarm.enabled,
          label: alarm.label,
          repeatDays: alarm.repeatDays,
          snoozeDuration: alarm.snoozeDuration,
          maxSnoozeCount: alarm.maxSnoozeCount,
          ringtoneUri: alarm.ringtoneUri,
          vibrationEnabled: alarm.vibrationEnabled,
          volume: alarm.volume,
          createdAt: alarm.createdAt,
          updatedAt: alarm.updatedAt
        };
      }
      return alarm;
    });
    
    this.alarmsData = updatedAlarms;
    this.updateNextAlarm();
  }
  
  private deleteAlarm(alarmId: string): void {
    const updatedAlarms = this.alarmsData.filter((alarm) => alarm.id !== alarmId);
    this.alarmsData = updatedAlarms;
    this.updateNextAlarm();
  }
  
  private editAlarm(alarmId: string): void {
    // Navigate to edit page
    router.pushUrl({
      url: 'pages/AlarmEdit/Index',
      params: { alarmId: alarmId }
    }).catch((err: Error) => {
      console.error('Failed to navigate to edit page:', err);
    });
  }
  
  build() {
    // Use GridRow for responsive layout
    GridRow({ columns: { sm: 4, md: 8, lg: 12 }, breakpoints: { value: ['320vp', '600vp', '840vp', '1440vp'] } }) {
      // Main content area
      GridCol({ span: { sm: 4, md: 8, lg: 12 } }) {
        Column() {
          // Header with current time
          this.buildHeader()
          
          // Content area - different layout based on screen size
          if (this.isMobile()) {
            this.buildMobileLayout()
          } else {
            this.buildDesktopLayout()
          }
        }
        .width('100%')
        .height('100%')
        .padding(20)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  

  
  @Builder
  buildMobileLayout() {
    Column() {
      // Add alarm button
      Button('Add Alarm')
        .width('80%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#2196F3')
        .fontColor(Color.White)
        .margin({ bottom: 24 })
        .onClick(() => this.addNewAlarm())
      
      // Alarm list
      if (this.alarmsData.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildAlarmList()
      }
    }
    .width('100%')
  }
  
  @Builder
  buildDesktopLayout() {
    Row() {
      // Left column - Alarm list
      Column() {
        Text('Alarms')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 24 })
          .width('100%')
          .textAlign(TextAlign.Start)
        
        if (this.alarmsData.length === 0) {
          this.buildEmptyState()
        } else {
          this.buildAlarmList()
        }
      }
      .width(this.isLargeScreen() ? '60%' : '50%')
      .padding({ right: 24 })
      
      // Right column - Add alarm form
      Column() {
        Text('Add New Alarm')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 24 })
          .width('100%')
          .textAlign(TextAlign.Start)
        
        this.buildAddAlarmForm()
      }
      .width(this.isLargeScreen() ? '40%' : '50%')
      .backgroundColor(Color.White)
      .borderRadius(16)
      .padding(24)
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildEmptyState() {
    Column() {
      // Using a text icon since we don't have image resources
      Text('⏰')
        .fontSize(64)
        .fontColor('#CCCCCC')
        .margin({ bottom: 24 })
      
      Text('No alarms set')
        .fontSize(18)
        .fontColor('#999999')
        .margin({ bottom: 12 })
      
      Text('Add an alarm to get started')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height(300)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  @Builder
  buildAlarmList() {
    AlarmList({
      alarmsData: $alarmsData,
      currentBreakpoint: $currentBreakpoint,
      showHeader: !this.isMobile(),
      onToggleAlarm: (alarmId: string) => {
        this.toggleAlarm(alarmId);
      },
      onEditAlarm: (alarmId: string) => {
        this.editAlarm(alarmId);
      },
      onDeleteAlarm: (alarmId: string) => {
        this.deleteAlarm(alarmId);
      }
    })
    .width('100%')
    .height(this.isMobile() ? '70%' : '400')
    .margin({ bottom: 24 })
  }
  

  
  @Builder
  buildAddAlarmForm() {
    Column({ space: 16 }) {
      // Time picker (simplified)
      Row() {
        Text('Time:')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
        
        Text('07:00')
          .fontSize(18)
          .fontColor('#2196F3')
          .fontWeight(FontWeight.Medium)
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#E3F2FD')
          .borderRadius(8)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      // Label input
      Row() {
        Text('Label:')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
        
        TextInput({ placeholder: 'Alarm label' })
          .width('100%')
          .height(40)
          .padding(8)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .border({ width: 1, color: '#E0E0E0' })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      // Repeat days
      Row() {
        Text('Repeat:')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
        
        Text('Never')
          .fontSize(14)
          .fontColor('#666666')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      // Snooze options
      Row() {
        Text('Snooze:')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
        
        Text('5 minutes, 3 times')
          .fontSize(14)
          .fontColor('#666666')
          .padding({ left: 12, right: 12, top: 8, bottom: 8 })
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      // Add button
      Button('Add Alarm')
        .width('100%')
        .height(48)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#2196F3')
        .fontColor(Color.White)
        .margin({ top: 24 })
        .onClick(() => this.addNewAlarm())
    }
    .width('100%')
  }
  
  // Continuation (migration) methods
  private setupMigrationListener(): void {
    // Listen for migration completion events
    // In a real app, you would listen for continuation events
    // For now, we'll simulate with a timeout
    setTimeout(() => {
      // Simulate migration events for demo
      console.log('Migration listener setup');
    }, 1000);
  }
  
  private async startDeviceDiscovery(): Promise<void> {
    try {
      this.isDiscoveringDevices = true;
      // Simulate device discovery for demo
      // In a real app, you would use: this.discoveredDevices = await this.continuationManager.startDiscovery();
      setTimeout(() => {
        this.discoveredDevices = [
          { deviceId: 'device_1', deviceName: 'Living Room Tablet', deviceType: 'tablet' },
          { deviceId: 'device_2', deviceName: 'Bedroom Phone', deviceType: 'phone' },
          { deviceId: 'device_3', deviceName: 'Kitchen Display', deviceType: 'display' }
        ];
        this.isDiscoveringDevices = false;
        console.info('Discovered devices:', this.discoveredDevices.length);
      }, 1500);
    } catch (error) {
      console.error('Failed to discover devices:', error);
      this.migrationStatus = 'Failed to discover devices';
      this.isDiscoveringDevices = false;
    }
  }
  
  private async stopDeviceDiscovery(): Promise<void> {
    try {
      await this.continuationManager.stopDiscovery();
      this.discoveredDevices = [];
    } catch (error) {
      console.error('Failed to stop device discovery:', error);
    }
  }
  
  private async migrateToDevice(device: DeviceInfo): Promise<void> {
    try {
      this.isMigrating = true;
      this.migrationStatus = `Migrating to ${device.deviceName}...`;
      // In a real implementation, you would call continuationManager.migrateToDevice(device)
      // For now, simulate migration
      setTimeout(() => {
        this.isMigrating = false;
        this.migrationStatus = `Migration to ${device.deviceName} successful`;
        this.discoveredDevices = [];
        
        // Clear status after 5 seconds
        setTimeout(() => {
          this.migrationStatus = '';
        }, 5000);
      }, 2000);
    } catch (error) {
      console.error('Migration failed:', error);
      this.migrationStatus = `Migration failed: ${(error as Error).message || 'Unknown error'}`;
      this.isMigrating = false;
      
      // Clear status after 5 seconds
      setTimeout(() => {
        this.migrationStatus = '';
      }, 5000);
    }
  }
  
  private cancelMigration(): void {
    this.continuationManager.cancelMigration().catch((error: Error) => {
      console.error('Failed to cancel migration:', error);
    });
    this.isMigrating = false;
    this.migrationStatus = 'Migration cancelled';
    
    // Clear status after 3 seconds
    setTimeout(() => {
      this.migrationStatus = '';
    }, 3000);
  }
  
  // Update buildHeader to include migration button
  @Builder
  buildHeader() {
    Column() {
      // Current time (large)
      Text(this.currentTime)
        .fontSize(this.isMobile() ? 48 : 64)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 8 })
      
      // Current date
      Text(this.currentDate)
        .fontSize(this.isMobile() ? 16 : 20)
        .fontColor('#666666')
        .margin({ bottom: 8 })
      
      // Next alarm info
      Text(this.nextAlarmTime)
        .fontSize(this.isMobile() ? 18 : 22)
        .fontColor('#2196F3')
        .margin({ bottom: 16 })
      
      // Migration status
      if (this.migrationStatus) {
        Text(this.migrationStatus)
          .fontSize(14)
          .fontColor(this.migrationStatus.includes('successful') ? '#4CAF50' : '#F44336')
          .margin({ bottom: 16 })
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      
      // Migration button (only show on larger screens)
      if (!this.isMobile()) {
        Row({ space: 8 }) {
          if (this.isDiscoveringDevices) {
            LoadingProgress()
              .width(20)
              .height(20)
              .color('#2196F3')
            
            Text('Discovering devices...')
              .fontSize(14)
              .fontColor('#666666')
          } else if (this.discoveredDevices.length > 0) {
            // Show discovered devices
            ForEach(this.discoveredDevices, (device: DeviceInfo) => {
              Button(device.deviceName || `Device ${device.deviceId}`)
                .fontSize(12)
                .padding({ left: 12, right: 12, top: 6, bottom: 6 })
                .backgroundColor('#E3F2FD')
                .fontColor('#2196F3')
                .borderRadius(4)
                .onClick(() => this.migrateToDevice(device))
                .enabled(!this.isMigrating)
            }, (device: DeviceInfo) => device.deviceId)
            
            Button('Stop Discovery')
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#FFEBEE')
              .fontColor('#F44336')
              .borderRadius(4)
              .onClick(() => this.stopDeviceDiscovery())
          } else {
            Button('Migrate to Another Device')
              .fontSize(14)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .backgroundColor(this.isMigrating ? '#CCCCCC' : '#4CAF50')
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => this.startDeviceDiscovery())
              .enabled(!this.isMigrating)
          }
          
          if (this.isMigrating) {
            Button('Cancel')
              .fontSize(12)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .backgroundColor('#FFEBEE')
              .fontColor('#F44336')
              .borderRadius(4)
              .onClick(() => this.cancelMigration())
          }
        }
        .margin({ bottom: 16 })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Center)
    .padding({ top: this.isMobile() ? 40 : 60, bottom: 32 })
  }
}