'''
自动化 python 脚本
main.py
'''

import os
import re
import shutil
import zipfile
import yaml

REG_STR = {
    'version_str': r'(\d+)\.(\d+)\.(\d+)\+(\d+)',
    'pubspec_yaml': r'version: (\d+\.\d+\.\d+\+\d+)',
    'release_yml': r'tag: "v(.*)"',
    'body_md': r'v(.*)',
    'installer_creator_iss': r'#define MyAppVersion "(.*)"',
}

FILE_DIR = {
    'pubspec_yaml': r'pubspec.yaml',
    'release_yml': r'.github\workflows\releases.yml',
    'body_md': r'.release_tool\body.md',
    'release_dir': r'build\windows\runner\Release',
    'release_tool_dir': r'.release_tool',
    'installer_creator_iss': r'.release_tool\installer_creator.iss',
    'commit_txt': r'commit.txt',
}


def get_version_from_pubspec_yaml() -> str:
    '''
    从 pubspec.yaml 文件中获取当前版本的字符串
    '''
    file = open(FILE_DIR['pubspec_yaml'], encoding='utf-8')
    data = yaml.load(file, Loader=yaml.FullLoader)
    result = data['version']
    file.close()
    return result


def rewrite_tool(file_dir: str, reg: str, repl: str) -> None:
    '''
    改写用辅助函数
    '''
    file = open(file_dir, 'r+', encoding='utf-8')
    text = file.read()
    file.seek(0, 0)
    text = re.sub(reg, repl, text)
    file.write(text)
    file.close()


def rewrite_version_in_pubspec_yaml(new_version: str) -> None:
    '''
    修改 pubspec.yaml 文件中的版本号
    '''
    rewrite_tool(
        file_dir=FILE_DIR['pubspec_yaml'],
        reg=REG_STR['pubspec_yaml'],
        repl=f'version: {new_version}',
    )


def rewrite_version_in_installer_creator_iss(new_version: str) -> None:
    '''
    修改 installer_creator.iss 文件中的版本号
    '''
    rewrite_tool(
        file_dir=FILE_DIR['installer_creator_iss'],
        reg=REG_STR['installer_creator_iss'],
        repl=f'#define MyAppVersion "{new_version}"',
    )


def rewrite_release_version(new_version: str) -> None:
    '''
    修改 release.yml 和 body.md 文件中的版本号
    '''

    rewrite_tool(
        file_dir=FILE_DIR['release_yml'],
        reg=REG_STR['release_yml'],
        repl=f'tag: "v{new_version}"',
    )
    rewrite_tool(
        file_dir=FILE_DIR['body_md'],
        reg=REG_STR['body_md'],
        repl=f'v{new_version}',
    )


def is_new_version_legal(current_version: str, new_version: str) -> bool:
    '''
    比较版本号大小, 两字符串格式类似 1.0.0+1
    '''
    current = re.match(REG_STR['version_str'], current_version)
    new = re.match(REG_STR['version_str'], new_version)

    if int(new[4]) < int(current[4]):
        print(f'> 新构建号 {new[4]} 应该不小于 {current[4]}')
        return False

    for i in range(1, 5):
        if int(new[i]) > int(current[i]):
            # 从最高级一一对比, 某级新版本若大于旧版本, 则确实新版本大
            # 返回 True
            return True
        if int(new[i]) < int(current[i]):
            # 从最高级一一对比, 某级新版本若小于旧版本, 则是新版本小了
            # 返回 False
            return False
    # 运行到这说明俩版本号一样大, 即重新构建该版本
    # 返回 True
    return True


def input_tool(
    first_message: str,
    rule: str,
    error_message: str,
    rule_function: any,
) -> str:
    '''
    根据 rule_function 获取合法的值
    '''
    # 提醒
    print(f'> {first_message} {rule}: ', end='')
    # 第一次输入
    input_str = input()
    # 当 rule_function(input_str) 返回 false
    # 即不合法时
    while not rule_function(input_str):
        # 重新提醒并输入
        print(f'> {error_message}')
        print(f'> {first_message} {rule}: ', end='')
        input_str = input()
    # 直至输入合法
    return input_str


def copy_tree(src_path: str, dst_path: str) -> None:
    '''
    复制 src_path 文件夹至 dst_path 目录下, 且要求俩者后不接 '/'
    '''
    if not os.path.isdir(src_path):
        print(f'> 所复制 {src_path} 不存在')
    else:
        if os.path.isdir(dst_path):
            shutil.rmtree(dst_path)
        shutil.copytree(src_path, dst_path)
        print(f'> 已复制 {src_path} 至 {dst_path} 下')


def zip_file(src_dir):
    '''
    压缩 src_dir 文件夹
    '''
    zip_name = src_dir + '.zip'
    zip_files = zipfile.ZipFile(zip_name, 'w', zipfile.ZIP_DEFLATED)
    for dirpath, _, filenames in os.walk(src_dir):
        fpath = dirpath.replace(src_dir, '')
        fpath = fpath and fpath + os.sep or ''
        for filename in filenames:
            zip_files.write(os.path.join(dirpath, filename), fpath + filename)

    zip_files.close()
    print(f'> 已压缩 {src_dir}.zip')


def main_module() -> None:
    '''
    主模块
    '''
    # 程序开始
    print('-- main.py --')
    current_version_str = get_version_from_pubspec_yaml()
    input_str = ''

    input_str = input_tool(
        first_message=f'是否更改当前版本 {current_version_str}',
        rule='(y/n)',
        error_message='请只输入 y 或 n',
        rule_function=lambda input_str: input_str == 'y' or input_str == 'n',
    )

    # 若输入的是 'y'
    if input_str == 'y':

        input_str = input_tool(
            first_message='请输入版本号',
            rule='',
            error_message='请确认版本号格式',
            rule_function=lambda input_str: re.search(
                REG_STR['version_str'],
                input_str,
            ),
        )

        # 当新版本号不合法时
        while not is_new_version_legal(current_version_str, input_str):
            # 重新提醒并输入
            print(f'> 请使得新输入的版本号 {input_str} 不小于旧版本号 {current_version_str}')
            input_str = input_tool(
                first_message='请输入版本号',
                rule='',
                error_message='请确认版本号格式',
                rule_function=lambda input_str: re.search(
                    REG_STR['version_str'],
                    input_str,
                ),
            )
        # 直至新版本号不大于原版本号

        # 写入新版本号至 pubspec.yaml 文件
        rewrite_version_in_pubspec_yaml(input_str)
        # 写入新版本号至 installer-creator.iss 文件
        rewrite_version_in_installer_creator_iss(input_str)

        # 版本号已修改
        print(f'> 版本号已修改为 {get_version_from_pubspec_yaml()}')

        # 修改版本号后自动构建
        os.system('flutter build windows')

        # # 并将 build 后的 Release 文件夹转移至 .release_tool/
        copy_tree(
            src_path=FILE_DIR['release_dir'],
            dst_path=f"{FILE_DIR['release_tool_dir']}/Release",
        )

        # 并进行压缩和打包
        zip_file(f"{FILE_DIR['release_tool_dir']}/Release")
        os.system(FILE_DIR["release_tool_dir"] + r'\installer_creator.bat')

    else:
        # 反之输入的不是 'y'
        print('> 已取消更改版本号')


def release_module() -> None:
    '''
    发布模块
    '''
    current_version_str = get_version_from_pubspec_yaml()
    input_str = ''

    input_str = input_tool(
        first_message=f'是否发布当前版本 {current_version_str}',
        rule='(y/n)',
        error_message='请只输入 y 或 n',
        rule_function=lambda input_str: input_str == 'y' or input_str == 'n',
    )

    # 若输入的是 'y'
    if input_str == 'y':
        # 修改发布版本
        rewrite_release_version(current_version_str)
        # 打开 body.md 文件进行修改
        print('> 已为你打开 body.md 文件')
        os.startfile(FILE_DIR['body_md'])

        # 打开文件后询问是否完成
        input_str = input_tool(
            first_message='是否完成修改',
            rule='(y)',
            error_message='请输入 y 以确认修改完成',
            rule_function=lambda input_str: input_str == 'y',
        )

        # 梳理逻辑, 本脚本分为两个模块
        # 1. 通过脚本修改版本号则保证 pubspec.yaml, installer_creator.iss, 程序版本一致
        # 2. 通过脚本发布软件保证 pubspec.yaml, body.md, tag 的版本一致
        # 一般流程为 1 -> 1 -> 1 -> 2 即多次修改版本号后发布, 无异常
        # 最后一步, 提交 release

        release_version_str = get_version_from_pubspec_yaml()
        print(f'> 正在发布 v{release_version_str}')
        os.system('git add .')

        print('> 已为你打开 commit.txt 文件')
        os.startfile(FILE_DIR['commit_txt'])

        # 打开文件后询问是否完成
        input_str = input_tool(
            first_message='是否完成修改',
            rule='(y)',
            error_message='请输入 y 以确认修改完成',
            rule_function=lambda input_str: input_str == 'y',
        )

        os.system(f'git commit -m "v{release_version_str}"')
        os.system('git push')
        os.system(f'git tag v{release_version_str}')
        os.system('git push --tags')
        print(f'> 已发布 v{release_version_str}, 请检查发布情况')

    else:
        # 反之输入的不是 'y'
        print('> 已取消发布程序')


if __name__ == '__main__':

    os.system('cls')

    # 进入 主模块
    main_module()

    # 进入 发布模块
    release_module()
