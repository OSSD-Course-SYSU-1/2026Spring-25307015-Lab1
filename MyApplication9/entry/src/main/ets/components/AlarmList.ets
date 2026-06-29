/**
 * Alarm List Component with responsive layout
 * Supports single column on mobile, multi-column on tablet/desktop
 */
import { AlarmData } from '../models/types';

@Component
export struct AlarmList {
  @Link alarmsData: AlarmData[];
  @Link currentBreakpoint: string;
  
  // Event handlers
  @Prop onToggleAlarm?: (alarmId: string) => void;
  @Prop onEditAlarm?: (alarmId: string) => void;
  @Prop onDeleteAlarm?: (alarmId: string) => void;
  
  // Configuration
  @Prop showHeader: boolean = true;
  @Prop emptyStateMessage: string = 'No alarms set';
  
  private isMobile(): boolean {
    return this.currentBreakpoint === 'sm' || this.currentBreakpoint === 'xs';
  }
  
  private isTablet(): boolean {
    return this.currentBreakpoint === 'md' || this.currentBreakpoint === 'lg';
  }
  
  private isLargeScreen(): boolean {
    return this.currentBreakpoint === 'xl';
  }
  
  private getColumns(): number {
    if (this.isMobile()) {
      return 1;
    } else if (this.isTablet()) {
      return 2;
    } else {
      return 3;
    }
  }
  
  build() {
    Column() {
      // Header
      if (this.showHeader) {
        this.buildHeader()
      }
      
      // Content
      if (this.alarmsData.length === 0) {
        this.buildEmptyState()
      } else {
        this.buildAlarmGrid()
      }
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildHeader() {
    Row() {
      Text('Alarms')
        .fontSize(this.isMobile() ? 20 : 24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .layoutWeight(1)
      
      Text(`${this.alarmsData.length} total`)
        .fontSize(14)
        .fontColor('#666666')
    }
    .width('100%')
    .padding({ bottom: 16 })
  }
  
  @Builder
  buildEmptyState() {
    Column() {
      Text('⏰')
        .fontSize(48)
        .fontColor('#CCCCCC')
        .margin({ bottom: 16 })
      
      Text(this.emptyStateMessage)
        .fontSize(16)
        .fontColor('#999999')
        .margin({ bottom: 8 })
      
      Text('Tap the + button to add an alarm')
        .fontSize(14)
        .fontColor('#999999')
    }
    .width('100%')
    .height(200)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
  }
  
  @Builder
  buildAlarmGrid() {
    if (this.getColumns() === 1) {
      // Single column layout for mobile
      this.buildSingleColumnList()
    } else {
      // Multi-column grid for tablet/desktop
      this.buildMultiColumnGrid()
    }
  }
  
  @Builder
  buildSingleColumnList() {
    List({ space: 12, initialIndex: 0 }) {
      ForEach(this.alarmsData, (alarm: AlarmData) => {
        ListItem() {
          this.buildAlarmItem(alarm)
        }
      }, (alarm: AlarmData) => alarm.id)
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildMultiColumnGrid() {
    GridRow({ columns: { sm: 1, md: 2, lg: 3 }, breakpoints: { value: ['320vp', '600vp', '840vp'] } }) {
      ForEach(this.alarmsData, (alarm: AlarmData) => {
        GridCol({ span: { sm: 1, md: 1, lg: 1 } }) {
          this.buildAlarmCard(alarm)
        }
        .margin({ bottom: 16, right: 16 })
      }, (alarm: AlarmData) => alarm.id)
    }
    .width('100%')
  }
  
  @Builder
  buildAlarmCard(alarm: AlarmData) {
    Column({ space: 8 }) {
      // Time display
      Row() {
        Text(`${alarm.hour.toString().padStart(2, '0')}:${alarm.minute.toString().padStart(2, '0')}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(alarm.enabled ? '#333333' : '#999999')
          .layoutWeight(1)
        
        // Status indicator
        Circle({ width: 12, height: 12 })
          .fill(alarm.enabled ? '#4CAF50' : '#F44336')
          .margin({ left: 8 })
      }
      .width('100%')
      
      // Alarm label
      Text(alarm.label || 'Alarm')
        .fontSize(14)
        .fontColor(alarm.enabled ? '#666666' : '#999999')
        .width('100%')
        .textAlign(TextAlign.Start)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      
      // Repeat days
      if (alarm.repeatDays && alarm.repeatDays.length > 0) {
        Text(this.formatRepeatDays(alarm.repeatDays))
          .fontSize(12)
          .fontColor('#2196F3')
          .width('100%')
          .textAlign(TextAlign.Start)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      
      Divider()
        .strokeWidth(1)
        .color('#EEEEEE')
        .margin({ top: 8, bottom: 8 })
      
      // Action buttons
      Row({ space: 8 }) {
        // Toggle button
        Button(alarm.enabled ? 'ON' : 'OFF')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor(alarm.enabled ? '#E8F5E9' : '#FFEBEE')
          .fontColor(alarm.enabled ? '#2E7D32' : '#C62828')
          .borderRadius(4)
          .onClick(() => {
            if (this.onToggleAlarm) {
              this.onToggleAlarm(alarm.id);
            }
          })
        
        // Edit button
        Button('Edit')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 4, bottom: 4 })
          .backgroundColor('#E3F2FD')
          .fontColor('#2196F3')
          .borderRadius(4)
          .onClick(() => {
            if (this.onEditAlarm) {
              this.onEditAlarm(alarm.id);
            }
          })
        
        // Delete button (only show on larger screens)
        if (!this.isMobile()) {
          Button('Delete')
            .fontSize(12)
            .padding({ left: 12, right: 12, top: 4, bottom: 4 })
            .backgroundColor('#FFEBEE')
            .fontColor('#F44336')
            .borderRadius(4)
            .onClick(() => {
              if (this.onDeleteAlarm) {
                this.onDeleteAlarm(alarm.id);
              }
            })
        }
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  @Builder
  buildAlarmItem(alarm: AlarmData) {
    Row() {
      // Time and label
      Column({ space: 4 }) {
        Text(`${alarm.hour.toString().padStart(2, '0')}:${alarm.minute.toString().padStart(2, '0')}`)
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor(alarm.enabled ? '#333333' : '#999999')
        
        Text(alarm.label || 'Alarm')
          .fontSize(14)
          .fontColor(alarm.enabled ? '#666666' : '#999999')
        
        if (alarm.repeatDays && alarm.repeatDays.length > 0) {
          Text(this.formatRepeatDays(alarm.repeatDays))
            .fontSize(12)
            .fontColor('#2196F3')
        }
      }
      .layoutWeight(1)
      
      // Status indicator and actions
      Column({ space: 8 }) {
        // Status indicator
        Circle({ width: 16, height: 16 })
          .fill(alarm.enabled ? '#4CAF50' : '#F44336')
        
        // Toggle switch
        Toggle({ type: ToggleType.Switch, isOn: alarm.enabled })
          .onChange((isOn: boolean) => {
            if (this.onToggleAlarm) {
              this.onToggleAlarm(alarm.id);
            }
          })
      }
      .alignItems(HorizontalAlign.End)
    }
    .width('100%')
    .padding(16)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({ radius: 4, color: '#0A000000', offsetX: 0, offsetY: 2 })
  }
  
  private formatRepeatDays(days: string[]): string {
    if (days.length === 0) return 'Never';
    if (days.length === 7) return 'Every day';
    if (days.length === 5 && 
        days.includes('Monday') && 
        days.includes('Tuesday') && 
        days.includes('Wednesday') && 
        days.includes('Thursday') && 
        days.includes('Friday')) {
      return 'Weekdays';
    }
    if (days.length === 2 && 
        days.includes('Saturday') && 
        days.includes('Sunday')) {
      return 'Weekends';
    }
    
    // Abbreviate day names
    const abbreviations: Record<string, string> = {
      'Sunday': 'Sun',
      'Monday': 'Mon', 
      'Tuesday': 'Tue',
      'Wednesday': 'Wed',
      'Thursday': 'Thu',
      'Friday': 'Fri',
      'Saturday': 'Sat'
    };
    
    return days.map(day => abbreviations[day] || day).join(', ');
  }
  

}