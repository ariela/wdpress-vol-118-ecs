#!/bin/sh
set -e

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# アプリケーション実行パス
APP_ROOT="/var/www/html"

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# artisanコマンドパス
ARTISAN_PATH="${APP_ROOT}/artisan"

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# コンテナ環境変数「CONTAINER_ROLE」(デフォルト：app)
role=${CONTAINER_ROLE:-app}

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# コンテナ環境変数「APP_ENV」(デフォルト：production)
env=${APP_ENV:-production}

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# コンテナ環境変数「SCHEDULE_INTERVAL」(デフォルト：1)
interval=${SCHEDULE_INTERVAL:-1}

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# コンテナ環境変数「SCHEDULE_STEP」(デフォルト：0)
step=${SCHEDULE_STEP:-0}

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# ログ出力
write_log () {
    echo -e "date:$(date +"%Y/%m/%d %H:%M:%S %Z")\tmessage:$1\terror:0\tCONTAINER_ROLE:${role}\tAPP_ENV:${env}\tSCHEDULE_INTERVAL:${interval}\tSCHEDULE_STEP:${step}"
}

write_error () {
    echo -e "date:$(date +"%Y/%m/%d %H:%M:%S %Z")\tmessage:$1\terror:1\tCONTAINER_ROLE:${role}\tAPP_ENV:${env}\tSCHEDULE_INTERVAL:${interval}\tSCHEDULE_STEP:${step}" 1>&2
}

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# アプリケーション実行

# カレントパスをアプリケーション実行パスに変更
cd ${APP_ROOT}

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# .envの切り替えを行う
if [ -f "${APP_ROOT}/.env.${env}" ]; then
    write_log "環境設定ファイル切替を実施：.env.${env}"
    cp -f ${APP_ROOT}/.env.${env} ${APP_ROOT}/.env
fi

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# APP_ENVが「local」以外の場合、設定のキャッシュ化を行う
if [ "$env" != "local" ]; then
    if [ -f "${ARTISAN_PATH}" ]; then
        write_log "設定のキャッシュを実施"
        php ${ARTISAN_PATH} config.cache &&
            php ${ARTISAN_PATH} route:cache &&
            php ${ARTISAN_PATH} view:cache
    fi
fi

#---+----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
# CONTAINER_ROLEにより実行する処理を変更する
if [ "$role" = "app" ]; then
    #----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
    # アプリケーションの実行
    write_log "アプリケーションの実行"
    exec php-fpm

elif [ "$role" = "queue" ]; then
    #----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
    # キュー処理の実行
    # 複数サーバを用意する際はキュードライバを共有可能なものに変更する必要があります。
    # https://readouble.com/laravel/6.x/ja/queues.html#driver-prerequisites
    if [ -f "${ARTISAN_PATH}" ]; then
        write_log "queue:workを実施"
        php ${ARTISAN_PATH} queue:work --verbose --tries=3 --timeout=90
    else
        write_error "artisanコマンドが見つからない為、${role}処理を終了しました。"
        exit 1
    fi
elif [ "$role" = "scheduler" ]; then
    #----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
    # スケジュール処理の実行(タスクスケジューリング用)
    # 同一ジョブを同時に複数サーバで実行させない場合は「memcached or redis (elasticache)」が必要となります。
    # https://readouble.com/laravel/6.x/ja/scheduling.html#running-tasks-on-one-server
    if [ -f "${ARTISAN_PATH}" ]; then
        write_log "schedule:runを単体実施"
        php ${ARTISAN_PATH} schedule:run --verbose --no-interaction
    else
        write_error "artisanコマンドが見つからない為、${role}処理を終了しました。"
        exit 1
    fi
elif [ "$role" = "scheduler-cron" ]; then
    #----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
    # スケジュール処理の実行
    # 同一ジョブを同時に複数サーバで実行させない場合は「memcached or redis (elasticache)」が必要となります。
    # https://readouble.com/laravel/6.x/ja/scheduling.html#running-tasks-on-one-server
    if [ -f "${ARTISAN_PATH}" ]; then
        write_log "schedule:runを繰り返し実施"
        # 分が切り替わるタイミングまで処理を遅延させる
        WAIT_TIME=$(( 60 - `date \+"%S"` ))
        if [ 0 -ne ${WAIT_TIME} ]; then
            write_log "処理の開始を${WAIT_TIME}秒待機します。"
            sleep ${WAIT_TIME}
        fi
        # 現在のステップ時間を取得
        NEXT_STEP_MIN=$(( ${interval} - ( ( `date \+"%M"` - ${step} ) % ${interval} ) ))
        if [ ${interval} -ne ${NEXT_STEP_MIN} ]; then
            write_log "次の処理時間まで${NEXT_STEP_MIN}分待機します。"
            sleep $(( ${NEXT_STEP_MIN} * 60 ))
        fi
        write_log "schedule:runの処理ループを開始"
        while [ true ]; do
            write_log "schedule:runを実施"
            php ${ARTISAN_PATH} schedule:run --verbose --no-interaction &
            # intervalで指定した分、スリープを行う
            sleep $(( 60 * ${interval} ))
        done
    else
        write_error "artisanコマンドが見つからない為、${role}処理を終了しました。"
        exit 1
    fi
else
    #----1----+----2----+----3----+----4----+----5----+----6----+----7----+----8----+----9----+----0
    # 存在しないロール
    write_error "指定されたロール「${role}」は存在しない為、${role}処理を終了しました。"
    exit 1
fi

