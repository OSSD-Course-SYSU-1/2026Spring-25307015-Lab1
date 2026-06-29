/**
 * Repeat Days Selector Component
 * Allows users to select which days of the week to repeat the alarm
 */
@Component
export struct RepeatDaysSelector {
  @Prop selectedDays: string[] = [];
  @State private days: string[] = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  @State private dayAbbreviations: string[] = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  
  // Event handler for selection change
  @Prop onChange?: (selectedDays: string[]) => void;
  
  private toggleDay(day: string): void {
    const newSelectedDays = [...this.selectedDays];
    const index = newSelectedDays.indexOf(day);
    
    if (index === -1) {
      newSelectedDays.push(day);
    } else {
      newSelectedDays.splice(index, 1);
    }
    
    // Sort days to maintain consistent order
    newSelectedDays.sort((a, b) => {
      const dayOrder = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      return dayOrder.indexOf(a) - dayOrder.indexOf(b);
    });
    
    if (this.onChange) {
      this.onChange(newSelectedDays);
    }
  }
  
  private isDaySelected(day: string): boolean {
    return this.selectedDays.includes(day);
  }
  
  private getDisplayText(): string {
    if (this.selectedDays.length === 0) {
      return 'Never';
    }
    
    if (this.selectedDays.length === 7) {
      return 'Every day';
    }
    
    if (this.selectedDays.length === 5 && 
        this.selectedDays.includes('Monday') && 
        this.selectedDays.includes('Tuesday') && 
        this.selectedDays.includes('Wednesday') && 
        this.selectedDays.includes('Thursday') && 
        this.selectedDays.includes('Friday')) {
      return 'Weekdays';
    }
    
    if (this.selectedDays.length === 2 && 
        this.selectedDays.includes('Saturday') && 
        this.selectedDays.includes('Sunday')) {
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
    
    return this.selectedDays.map(day => abbreviations[day] || day).join(', ');
  }
  
  private selectAllDays(): void {
    const allDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    if (this.onChange) {
      this.onChange([...allDays]);
    }
  }
  
  private clearAllDays(): void {
    if (this.onChange) {
      this.onChange([]);
    }
  }
  
  private selectWeekdays(): void {
    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    if (this.onChange) {
      this.onChange([...weekdays]);
    }
  }
  
  private selectWeekends(): void {
    const weekends = ['Saturday', 'Sunday'];
    if (this.onChange) {
      this.onChange([...weekends]);
    }
  }
  
  build() {
    Column({ space: 16 }) {
      // Display current selection
      Row() {
        Text('Repeat:')
          .fontSize(16)
          .fontColor('#333333')
          .width(80)
        
        Text(this.getDisplayText())
          .fontSize(16)
          .fontColor('#2196F3')
          .fontWeight(FontWeight.Medium)
          .layoutWeight(1)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      // Quick selection buttons
      Row({ space: 8 }) {
        Button('Every day')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.selectedDays.length === 7 ? '#2196F3' : '#E3F2FD')
          .fontColor(this.selectedDays.length === 7 ? Color.White : '#2196F3')
          .borderRadius(4)
          .onClick(() => this.selectAllDays())
        
        Button('Weekdays')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(
            this.selectedDays.length === 5 && 
            this.selectedDays.includes('Monday') && 
            this.selectedDays.includes('Tuesday') && 
            this.selectedDays.includes('Wednesday') && 
            this.selectedDays.includes('Thursday') && 
            this.selectedDays.includes('Friday') ? '#2196F3' : '#E3F2FD'
          )
          .fontColor(
            this.selectedDays.length === 5 && 
            this.selectedDays.includes('Monday') && 
            this.selectedDays.includes('Tuesday') && 
            this.selectedDays.includes('Wednesday') && 
            this.selectedDays.includes('Thursday') && 
            this.selectedDays.includes('Friday') ? Color.White : '#2196F3'
          )
          .borderRadius(4)
          .onClick(() => this.selectWeekdays())
        
        Button('Weekends')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(
            this.selectedDays.length === 2 && 
            this.selectedDays.includes('Saturday') && 
            this.selectedDays.includes('Sunday') ? '#2196F3' : '#E3F2FD'
          )
          .fontColor(
            this.selectedDays.length === 2 && 
            this.selectedDays.includes('Saturday') && 
            this.selectedDays.includes('Sunday') ? Color.White : '#2196F3'
          )
          .borderRadius(4)
          .onClick(() => this.selectWeekends())
        
        Button('Clear')
          .fontSize(12)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .backgroundColor(this.selectedDays.length === 0 ? '#F44336' : '#FFEBEE')
          .fontColor(this.selectedDays.length === 0 ? Color.White : '#F44336')
          .borderRadius(4)
          .onClick(() => this.clearAllDays())
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      
      // Day selection grid
      GridRow({ columns: 7, gutter: { x: 8, y: 8 } }) {
        ForEach(this.days, (day: string, index: number) => {
          GridCol() {
            Column({ space: 4 }) {
              // Day abbreviation
              Text(this.dayAbbreviations[index])
                .fontSize(14)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.isDaySelected(day) ? Color.White : '#666666')
              
              // Day number (for visual representation)
              Circle({ width: 32, height: 32 })
                .fill(this.isDaySelected(day) ? '#2196F3' : '#F5F5F5')
                .border({ width: 2, color: this.isDaySelected(day) ? '#2196F3' : '#E0E0E0' })
              
              // Full day name (hidden on small screens)
              Text(day.substring(0, 3))
                .fontSize(10)
                .fontColor(this.isDaySelected(day) ? '#2196F3' : '#999999')
            }
            .width('100%')
            .height(80)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor(this.isDaySelected(day) ? '#E3F2FD' : Color.White)
            .borderRadius(8)
            .padding(8)
            .onClick(() => this.toggleDay(day))
          }
        }, (day: string) => day)
      }
      .width('100%')
      .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FAFAFA')
    .borderRadius(12)
    .border({ width: 1, color: '#E0E0E0' })
  }
  

}