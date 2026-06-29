/**
 * Alarm Edit Page
 * For adding new alarms or editing existing ones
 */
import router from '@ohos.router';
import { CustomTimePicker } from '../../components/CustomTimePicker';
import { RepeatDaysSelector } from '../../components/RepeatDaysSelector';
import { Alarm, AlarmManager, WeekDay } from '../../models/Alarm';
import { AlarmData } from '../../models/types';

@Entry
@Component
struct AlarmEdit {
  @State alarmData: AlarmData = {
    id: '',
    hour: 7,
    minute: 0,
    enabled: true,
    label: '',
    repeatDays: [],
    snoozeDuration: 5,
    maxSnoozeCount: 3,
    ringtoneUri: 'system://alarm_default',
    vibrationEnabled: true,
    volume: 80,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString()
  };
  
  @State isEditing: boolean = false;
  @State labelInput: string = '';
  @State snoozeDuration: number = 5;
  @State maxSnoozeCount: number = 3;
  @State vibrationEnabled: boolean = true;
  @State volume: number = 80;
  
  aboutToAppear(): void {
    // Get alarm data from router params if editing
    const params = router.getParams();
    if (params && typeof params === 'object') {
      const paramsObj = params as Record<string, string>;
      if (paramsObj['alarmId']) {
        const alarmId = paramsObj['alarmId'] as string;
        this.isEditing = true;
        const alarm = AlarmManager.getAlarm(alarmId);
      if (alarm) {
        this.alarmData = {
          id: alarm.id,
          hour: alarm.hour,
          minute: alarm.minute,
          enabled: alarm.enabled,
          label: alarm.label,
          repeatDays: alarm.repeatDays as string[], // Convert WeekDay[] to string[]
          snoozeDuration: alarm.snoozeDuration,
          maxSnoozeCount: alarm.maxSnoozeCount,
          ringtoneUri: alarm.ringtoneUri,
          vibrationEnabled: alarm.vibrationEnabled,
          volume: alarm.volume,
          createdAt: alarm.createdAt.toISOString(),
          updatedAt: alarm.updatedAt.toISOString()
        };
        this.labelInput = alarm.label;
        this.snoozeDuration = alarm.snoozeDuration;
        this.maxSnoozeCount = alarm.maxSnoozeCount;
        this.vibrationEnabled = alarm.vibrationEnabled;
        this.volume = alarm.volume;
      }
      }
    } else {
      // New alarm
      this.alarmData.id = 'alarm_' + Date.now();
      this.labelInput = 'Alarm';
    }
  }
  
  private saveAlarm(): void {
    // Update alarm data
    const updatedAlarm: AlarmData = {
      id: this.alarmData.id,
      hour: this.alarmData.hour,
      minute: this.alarmData.minute,
      enabled: this.alarmData.enabled,
      label: this.labelInput || 'Alarm',
      repeatDays: this.alarmData.repeatDays,
      snoozeDuration: this.snoozeDuration,
      maxSnoozeCount: this.maxSnoozeCount,
      ringtoneUri: this.alarmData.ringtoneUri,
      vibrationEnabled: this.vibrationEnabled,
      volume: this.volume,
      createdAt: this.alarmData.createdAt,
      updatedAt: new Date().toISOString()
    };
    
    if (this.isEditing) {
      // Update existing alarm
      AlarmManager.updateAlarm(Alarm.fromObject(updatedAlarm));
    } else {
      // Add new alarm
      updatedAlarm.createdAt = new Date().toISOString();
      AlarmManager.addAlarm(Alarm.fromObject(updatedAlarm));
    }
    
    // Navigate back
    router.back();
  }
  
  private deleteAlarm(): void {
    if (this.isEditing) {
      AlarmManager.deleteAlarm(this.alarmData.id);
    }
    router.back();
  }
  
  private cancel(): void {
    router.back();
  }
  
  private handleTimeChange(hour: number, minute: number): void {
    this.alarmData.hour = hour;
    this.alarmData.minute = minute;
  }
  
  private handleRepeatDaysChange(selectedDays: string[]): void {
    this.alarmData.repeatDays = selectedDays;
  }
  
  private incrementSnoozeDuration(): void {
    if (this.snoozeDuration < 30) {
      this.snoozeDuration += 5;
    }
  }
  
  private decrementSnoozeDuration(): void {
    if (this.snoozeDuration > 5) {
      this.snoozeDuration -= 5;
    }
  }
  
  private incrementSnoozeCount(): void {
    if (this.maxSnoozeCount < 10) {
      this.maxSnoozeCount += 1;
    }
  }
  
  private decrementSnoozeCount(): void {
    if (this.maxSnoozeCount > 1) {
      this.maxSnoozeCount -= 1;
    }
  }
  
  private incrementVolume(): void {
    if (this.volume < 100) {
      this.volume += 10;
    }
  }
  
  private decrementVolume(): void {
    if (this.volume > 0) {
      this.volume -= 10;
    }
  }
  
  private toggleVibration(): void {
    this.vibrationEnabled = !this.vibrationEnabled;
  }
  
  build() {
    Column({ space: 0 }) {
      // Header
      this.buildHeader()
      
      // Content
      Scroll() {
        Column({ space: 24 }) {
          // Time selection
          this.buildTimeSection()
          
          // Label input
          this.buildLabelSection()
          
          // Repeat days
          this.buildRepeatSection()
          
          // Snooze settings
          this.buildSnoozeSection()
          
          // Sound and vibration
          this.buildSoundSection()
        }
        .width('100%')
        .padding(24)
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off)
      
      // Footer buttons
      this.buildFooter()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
  
  @Builder
  buildHeader() {
    Row() {
      // Back button
      Button('Cancel')
        .fontSize(16)
        .fontColor('#2196F3')
        .backgroundColor(Color.Transparent)
        .onClick(() => this.cancel())
      
      Text(this.isEditing ? 'Edit Alarm' : 'New Alarm')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      // Delete button (only for editing)
      if (this.isEditing) {
        Button('Delete')
          .fontSize(16)
          .fontColor('#F44336')
          .backgroundColor(Color.Transparent)
          .onClick(() => this.deleteAlarm())
      } else {
        // Empty space to balance layout
        Text('')
          .width(60)
      }
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor(Color.White)
    .border({ width: { bottom: 1 }, color: '#E0E0E0' })
  }
  
  @Builder
  buildTimeSection() {
    Column({ space: 16 }) {
      Text('Time')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      CustomTimePicker({
        hour: this.alarmData.hour,
        minute: this.alarmData.minute,
        onChange: (hour: number, minute: number) => {
          this.handleTimeChange(hour, minute);
        }
      })
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildLabelSection() {
    Column({ space: 16 }) {
      Text('Label')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      TextInput({ text: this.labelInput, placeholder: 'Alarm label' })
        .width('100%')
        .height(48)
        .fontSize(16)
        .padding(12)
        .backgroundColor('#FAFAFA')
        .borderRadius(8)
        .border({ width: 1, color: '#E0E0E0' })
        .onChange((value: string) => {
          this.labelInput = value;
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildRepeatSection() {
    Column({ space: 16 }) {
      Text('Repeat')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      RepeatDaysSelector({
        selectedDays: this.alarmData.repeatDays,
        onChange: (selectedDays: string[]) => {
          this.handleRepeatDaysChange(selectedDays);
        }
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildSnoozeSection() {
    Column({ space: 16 }) {
      Text('Snooze')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      // Snooze duration
      Row() {
        Text('Duration:')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Row({ space: 16 }) {
          Button('-')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#E3F2FD')
            .fontColor('#2196F3')
            .borderRadius(20)
            .onClick(() => this.decrementSnoozeDuration())
          
          Text(`${this.snoozeDuration} minutes`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width(120)
            .textAlign(TextAlign.Center)
          
          Button('+')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#E3F2FD')
            .fontColor('#2196F3')
            .borderRadius(20)
            .onClick(() => this.incrementSnoozeDuration())
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      
      // Max snooze count
      Row() {
        Text('Max times:')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Row({ space: 16 }) {
          Button('-')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#E3F2FD')
            .fontColor('#2196F3')
            .borderRadius(20)
            .onClick(() => this.decrementSnoozeCount())
          
          Text(`${this.maxSnoozeCount} times`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width(120)
            .textAlign(TextAlign.Center)
          
          Button('+')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#E3F2FD')
            .fontColor('#2196F3')
            .borderRadius(20)
            .onClick(() => this.incrementSnoozeCount())
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildSoundSection() {
    Column({ space: 16 }) {
      Text('Sound & Vibration')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .width('100%')
        .textAlign(TextAlign.Start)
      
      // Volume control
      Row() {
        Text('Volume:')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Row({ space: 16 }) {
          Button('-')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#E3F2FD')
            .fontColor('#2196F3')
            .borderRadius(20)
            .onClick(() => this.decrementVolume())
          
          Text(`${this.volume}%`)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width(80)
            .textAlign(TextAlign.Center)
          
          Button('+')
            .width(40)
            .height(40)
            .fontSize(20)
            .backgroundColor('#E3F2FD')
            .fontColor('#2196F3')
            .borderRadius(20)
            .onClick(() => this.incrementVolume())
        }
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      
      // Vibration toggle
      Row() {
        Text('Vibration:')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Toggle({ type: ToggleType.Switch, isOn: this.vibrationEnabled })
          .onChange((isOn: boolean) => {
            this.toggleVibration();
          })
          .layoutWeight(1)
      }
      .width('100%')
      
      // Ringtone selection (simplified)
      Row() {
        Text('Sound:')
          .fontSize(16)
          .fontColor('#666666')
          .width(100)
        
        Text('Default Alarm')
          .fontSize(16)
          .fontColor('#333333')
          .layoutWeight(1)
        
        Text('→')
          .fontSize(20)
          .fontColor('#999999')
      }
      .width('100%')
      .padding({ top: 8, bottom: 8 })
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      .onClick(() => {
        // In a real app, this would open a ringtone picker
        console.log('Open ringtone picker');
      })
    }
    .width('100%')
    .padding(20)
    .backgroundColor(Color.White)
    .borderRadius(16)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildFooter() {
    Row({ space: 16 }) {
      Button('Save')
        .width('100%')
        .height(56)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#2196F3')
        .fontColor(Color.White)
        .borderRadius(12)
        .onClick(() => this.saveAlarm())
    }
    .width('100%')
    .padding(24)
    .backgroundColor(Color.White)
    .border({ width: { top: 1 }, color: '#E0E0E0' })
  }
}