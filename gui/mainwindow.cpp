#include "mainwindow.h"
#include "ui_mainwindow.h"

#include <QTimer>
#include <QTime>
#include <QApplication>
#include <QHeaderView>
#include <QKeyEvent>
#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <QFileDialog>

//#include "Vhrmcpu_hrmcpu.h"
//#include "Vhrmcpu_PROG.h"

MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
    ui->setupUi(this);

    // Clock Initialization
    clk = true;

    bgColor = QString("background-color: rgb(0, 0, 255); color: rgb(255, 255, 255);");

    // Create our design model with Verilator
    top = new Vtop;
    top->clk = clk;
    top->eval(); // initialize (so PROG gets loaded)

    // Verilated::internalsDump();  // See scopes to help debug

    // init trace dump
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    //tfp->spTrace()->set_time_resolution ("1 ps");
    tfp->open ("top.vcd");
    tfp->dump(main_time);
    tfp->flush(); // any impact on perf? not relevant here

    m_timer = new QTimer(this);
    QObject::connect(m_timer, SIGNAL(timeout()), this, SLOT(clkTick()));

    ttr_pbPUSH = 0;

    updateUI();

    image = QImage(640, 480, QImage::Format_Indexed8);

    // create the color 8 bit map
    for(int r=0;r<2;r++)
        for(int g=0;g<2;g++)
            for(int b=0;b<2;b++) {
                image.setColor(4*r+2*g+b,qRgb(255*r, 255*g, 255*b));
            }

    ui->screen->setPixmap(QPixmap::fromImage(image));

}

MainWindow::~MainWindow()
{
    // we close vcd:
    tfp->flush(); // any impact on perf? not relevant here
    tfp->close();

    delete ui;
}

void MainWindow::clkTick()
{
//    clk = ! clk;
//    main_time++;

//    top->clk = clk;

//    updateUI();

    int prev_x=0;
    int prev_y=0;

    while( true ) {
        clk = ! clk;
        main_time++;
        top->clk = clk;
        top->eval();
        if(ui->actionGenerate_Trace->isChecked()) tfp->dump(main_time);

        // update pixels in image (~ framwbuffer)
        if(top->top__DOT__activevideo3) {
            image.setPixel(top->top__DOT__px_x3, top->top__DOT__px_y3, top->rgb);
        }

        // when last pixel is reached, update "screen" widget
        if( prev_x == 639 && prev_y == 479 && clk) {
            ui->screen->setPixmap(QPixmap::fromImage(image));
            break;
        }
        prev_x = top->top__DOT__px_x3;
        prev_y = top->top__DOT__px_y3;
    }
    updateUI();
    if(ui->actionGenerate_Trace->isChecked()) tfp->flush();
}

void MainWindow::on_pbA_pressed()
{
    clkTick();
}

void MainWindow::on_pbB_toggled(bool checked)
{
    if(checked) {
        ui->pbA->setDisabled(true);
        ui->pbINSTR->setDisabled(true);
//        ui->pbReset->setDisabled(true);
        m_timer->start( ui->clkPeriod->value() );
    } else {
        m_timer->stop();
        ui->pbA->setEnabled(true);
        if(!ui->pbReset->isChecked())
           ui->pbINSTR->setEnabled(true);
//        ui->pbReset->setEnabled(true);

    }
}

void MainWindow::updateUI()
{
    bool toUintSuccess;

    // update INPUTS before we EVAL()
//    top->cpu_in_wr = ui->pbPUSH->isChecked();
//    top->cpu_in_data = ui->editINdata->text().toUInt(&toUintSuccess,16); //ui->editINdata->text().toInt();

    top->eval();
    if(ui->actionGenerate_Trace->isChecked()) {
        tfp->dump(main_time);
        tfp->flush();
    }

    // Control Block
    ui->clk->setState( clk );
    ui->main_time->setText( QString("%1").arg( main_time ) );

    // VGA Block
    ui->led_activevideo->setState(top->top__DOT__activevideo3);
    ui->hc->setText(formatData( top->top__DOT__vga_sync0__DOT__hc, 4, 10 )); // TODO //
    ui->vc->setText(formatData( top->top__DOT__vga_sync0__DOT__vc, 4, 10 )); // TODO //
    ui->px_x->setText(formatData( top->top__DOT__px_x3, 4, 10 )); // TODO //
    ui->px_y->setText(formatData( top->top__DOT__px_y3, 4, 10 )); // TODO //
    if(top->top__DOT__activevideo3) {
        image.setPixel(top->top__DOT__px_x3, top->top__DOT__px_y3, top->rgb);
    }

    // LEDS
    ui->R_LEDs->setText(formatData( top->leds ));
    ui->led0->setState( top->leds >> 0 & 1 );
    ui->led1->setState( top->leds >> 1 & 1 );
    ui->led2->setState( top->leds >> 2 & 1 );
    ui->led3->setState( top->leds >> 3 & 1 );
    ui->led4->setState( top->leds >> 4 & 1 );
    ui->led5->setState( top->leds >> 5 & 1 );
    ui->led6->setState( top->leds >> 6 & 1 );
    ui->led7->setState( top->leds >> 7 & 1 );

}

void MainWindow::highlightLabel(QWidget *qw, bool signal) {
    if( clk==0 && signal ) {
        qw->setStyleSheet(bgColor);
    } else if (clk==0 && signal == 0) {
        qw->setStyleSheet("");
    }
}

void MainWindow::on_clkPeriod_valueChanged(int period)
{
    m_timer->setInterval(period);
}

void MainWindow::keyPressEvent(QKeyEvent *e)
{
    if(e->key() == Qt::Key_F5) {
        ui->pbB->toggle();
    } else if(e->key() == Qt::Key_F3) {
        ui->pbA->click();
    } else if(e->key() == Qt::Key_F4) {
        ui->pbINSTR->click();
    }

}

void MainWindow::on_pbReset_toggled(bool checked)
{
    ui->pbINSTR->setDisabled(checked);

//    top->i_rst=checked;
    updateUI();
}

void MainWindow::on_pbSave_pressed()
{
    VerilatedSave os;
//    os.open(filenamep);
//    os << main_time;  // user code must save the timestamp, etc
//    os << *topp;

}

QString MainWindow::verilatorString( WData data[] )
{
    QString s;

    char* p;
    p=(char*)data;

    for(int i=12; i>0; i--) {
        if( p[i-1]>0 ) s.append( p[i-1] );
    }

    return s;
}

QString MainWindow::formatData(CData data) {
    // for now we don't use mode
    return QString("%1").arg( data, 2, 16, QChar('0')).toUpper();
    // ASCII mode --> return QString("%1").arg( QChar(data) );
}

QString MainWindow::formatData(CData data, char n, char base) {
    return QString("%1").arg( data, n, base, QChar('0')).toUpper();
}


void MainWindow::on_actionLoad_Program_triggered()
{
//    on_pbLoadPROG_pressed();
}

void MainWindow::on_actionExit_triggered()
{
    QApplication::quit();
}

void MainWindow::on_pbINSTR_pressed()
{
//    if( top->hrmcpu__DOT__IR0_rIR == 0 && !top->hrmcpu__DOT__INBOX_empty_n ) {
//        clkTick();
//        clkTick();
//        if( !top->cpu_in_wr || ui->editINdata->text().isEmpty() ) {
//            return;
//        }
//    }
//    while( top->hrmcpu__DOT__ControlUnit0__DOT__state == 9 /* = DECODE */ && top->hrmcpu__DOT__IR0_rIR != 240 /* != HALT */ ) {
//        clkTick();
//    }
//    while( top->hrmcpu__DOT__ControlUnit0__DOT__state != 9 /* DECODE */ && top->hrmcpu__DOT__IR0_rIR != 240 /* HALT */ ) {
//        clkTick();
//    }



}

void MainWindow::on_pbLoad_pressed()
{

}
