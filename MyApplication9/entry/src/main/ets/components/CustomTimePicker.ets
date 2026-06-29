/**
 * Custom Time Picker Component
 * Provides a user-friendly time selection interface
 */
@Component
export struct CustomTimePicker {
  @Prop hour: number = 7;
  @Prop minute: number = 0;
  @State private showPicker: boolean = false;
  @State private tempHour: number = 7;
  @State private tempMinute: number = 0;
  
  // Event handler for time change
  @Prop onChange?: (hour: number, minute: number) => void;
  
  aboutToAppear(): void {
    this.tempHour = this.hour;
    this.tempMinute = this.minute;
  }
  
  private togglePicker(): void {
    this.showPicker = !this.showPicker;
    if (this.showPicker) {
      this.tempHour = this.hour;
      this.tempMinute = this.minute;
    }
  }
  
  private confirmTime(): void {
    this.showPicker = false;
    if (this.onChange && (this.tempHour !== this.hour || this.tempMinute !== this.minute)) {
      this.onChange(this.tempHour, this.tempMinute);
    }
  }
  
  private cancelTime(): void {
    this.showPicker = false;
    this.tempHour = this.hour;
    this.tempMinute = this.minute;
  }
  
  private incrementHour(): void {
    this.tempHour = (this.tempHour + 1) % 24;
  }
  
  private decrementHour(): void {
    this.tempHour = (this.tempHour - 1 + 24) % 24;
  }
  
  private incrementMinute(): void {
    this.tempMinute = (this.tempMinute + 1) % 60;
  }
  
  private decrementMinute(): void {
    this.tempMinute = (this.tempMinute - 1 + 60) % 60;
  }
  
  private getTimeString(): string {
    const hourStr = this.hour.toString().padStart(2, '0');
    const minuteStr = this.minute.toString().padStart(2, '0');
    return `${hourStr}:${minuteStr}`;
  }
  
  private getTempTimeString(): string {
    const hourStr = this.tempHour.toString().padStart(2, '0');
    const minuteStr = this.tempMinute.toString().padStart(2, '0');
    return `${hourStr}:${minuteStr}`;
  }
  
  build() {
    Column({ space: 8 }) {
      // Time display button
      Button(this.getTimeString())
        .width(120)
        .height(48)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .backgroundColor('#E3F2FD')
        .fontColor('#2196F3')
        .borderRadius(8)
        .onClick(() => this.togglePicker())
      
      // Time picker popup
      if (this.showPicker) {
        Column({ space: 16 }) {
          // Time display
          Text(this.getTempTimeString())
            .fontSize(32)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ top: 16 })
          
          // Time controls
          Row({ space: 32 }) {
            // Hour controls
            Column({ space: 8 }) {
              Button('+')
                .width(48)
                .height(48)
                .fontSize(24)
                .backgroundColor('#E3F2FD')
                .fontColor('#2196F3')
                .borderRadius(24)
                .onClick(() => this.incrementHour())
              
              Text('Hour')
                .fontSize(14)
                .fontColor('#666666')
              
              Text(this.tempHour.toString().padStart(2, '0'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ top: 8, bottom: 8 })
              
              Button('-')
                .width(48)
                .height(48)
                .fontSize(24)
                .backgroundColor('#E3F2FD')
                .fontColor('#2196F3')
                .borderRadius(24)
                .onClick(() => this.decrementHour())
            }
            
            // Colon separator
            Text(':')
              .fontSize(32)
              .fontWeight(FontWeight.Bold)
              .fontColor('#333333')
              .margin({ top: 24 })
            
            // Minute controls
            Column({ space: 8 }) {
              Button('+')
                .width(48)
                .height(48)
                .fontSize(24)
                .backgroundColor('#E3F2FD')
                .fontColor('#2196F3')
                .borderRadius(24)
                .onClick(() => this.incrementMinute())
              
              Text('Minute')
                .fontSize(14)
                .fontColor('#666666')
              
              Text(this.tempMinute.toString().padStart(2, '0'))
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ top: 8, bottom: 8 })
              
              Button('-')
                .width(48)
                .height(48)
                .fontSize(24)
                .backgroundColor('#E3F2FD')
                .fontColor('#2196F3')
                .borderRadius(24)
                .onClick(() => this.decrementMinute())
            }
          }
          
          // Action buttons
          Row({ space: 16 }) {
            Button('Cancel')
              .width(120)
              .height(40)
              .fontSize(16)
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .borderRadius(8)
              .onClick(() => this.cancelTime())
            
            Button('OK')
              .width(120)
              .height(40)
              .fontSize(16)
              .fontWeight(FontWeight.Medium)
              .backgroundColor('#2196F3')
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => this.confirmTime())
          }
          .margin({ top: 24, bottom: 16 })
        }
        .width(300)
        .padding(24)
        .backgroundColor(Color.White)
        .borderRadius(16)
        .shadow({ radius: 16, color: '#1A000000', offsetX: 0, offsetY: 8 })
        .margin({ top: 16 })
      }
    }
  }
  

}